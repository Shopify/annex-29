# annex-29

## What this codebase does

annex-29 is a small Ruby gem (`annex_29`, Ruby 3.2 or later) that implements Unicode text segmentation as described in Unicode Standard Annex 29. Today it exposes one function, `Annex29.segment_words(input)`, which splits a string into words and returns an array of strings.

The gem has no runtime dependencies, no network access, no database, no file access and no user accounts. It runs inside the process of the application that calls it, and it handles whatever text that application passes in. That text is often untrusted: user-written names, addresses, search queries, messages and imported files.

The code is small and has four parts:

- `lib/annex_29.rb` is the public entry point. `segment_words` coerces its argument with `String(input)` and calls the segmenter.
- `lib/annex_29/word_segmentation.rl.erb` is the source of the segmenter. An ERB template reads the Unicode property files in `data/` and renders a Ragel grammar. The grammar describes the word, number, Hangul, Katakana, Han, Hiragana, emoji and flag rules, and it has the `call` method that runs the machine.
- `lib/annex_29/word_segmentation.rb` is generated from the grammar with `ragel -R -T1`. It is thousands of lines of state tables and is not written by hand.
- `Rakefile` renders the template and runs `ragel`. `data/` holds the Unicode reference files, and `spec/` runs the official word-break conformance cases.

## Auth shape

This gem has no authentication or authorization. It has no credentials, tokens, sessions, roles or secrets, and it makes no trust decision. Do not report a missing auth check.

The trust boundary is the argument of `Annex29.segment_words`. Treat it as attacker-controlled text of any length, any encoding and any mix of scripts, including combining marks, zero-width joiners, emoji sequences and unpaired or invalid code units.

The second trust boundary is the release path. The gem is built from `git ls-files` by `annex_29.gemspec`, the push host is restricted by `allowed_push_host`, and `.github/workflows/` runs CI and a contributor license check on pull requests.

## Threat model

An attacker who controls text that reaches a caller wants to make the caller slow, make it run out of memory, or make it crash. Ranked by impact: the caller stops answering because segmentation takes too long, the caller's memory grows without bound, the caller raises an unexpected exception, and a wrong segmentation changes what downstream code decides about a word.

A second, smaller concern is the supply chain. Anyone who can change the build inputs (the template, the Rakefile, the data files, the workflows) can change the code that ships.

Reviewer's checklist for the first concern:

- Regex cost (ReDoS): the segmenter is a Ragel state machine that reads each code point once. Check that no `Regexp`, `String#scan`, `gsub`, `match` or `=~` is applied to caller text in `lib/`. Regexes in the template run on the trusted `data/` files at build time only.
- Linear work: check that `call` in the template stays one pass over the input, with no nested loops, no re-scanning from the start of the input and no recursion that depends on input length.
- Unbounded memory: check that memory stays proportional to the input length. `call` builds one array of code points and one array of result words. Flag any new buffer, cache, memoization or intermediate string that grows with input or with the number of calls and is never released.
- Input coercion and encoding: check `segment_words` and `call` for the way they coerce and iterate the input (`String(input)`, `each_char`, `ord`, `pack("U*")`). Flag changes that skip coercion, assume UTF-8 or change which exception a bad input raises.
- Output integrity: check that words are cut from the input by the position markers `ts` and `te` and that no code path drops, repeats or reorders characters.

## Project-specific patterns to flag

- A `Regexp`, `String#scan`, `gsub`, `match` or `=~` on the argument of `segment_words` or on any value derived from it. Example: a "cleanup" step added before `call`.
- A new data structure in `call` that keeps input-sized state between calls. Example: a class-level Hash or Array that stores words or code points.
- A grammar rule in `word_segmentation.rl.erb` that adds a long or nested repetition (`(...)*` inside `(...)*`) over classes that overlap, or an action that scans backwards. Check that the machine still reads each code point a bounded number of times.
- `ERB.new(...).result`, `eval`, `instance_eval`, `send`, `Kernel#open`, backticks or `sh` with a string built from input, from environment variables or from the content of a data file. Example: a Rake task that interpolates a file name into a shell command.
- A `data/*.txt` line format change in `parse_unicode_data` that lets a malformed line become Ragel source. Check that only hex code points and category names reach the rendered grammar.
- A workflow in `.github/workflows/` that runs pull request code with a write token or a secret. Example: `pull_request_target` or `issue_comment` triggers that check out and run the head of a pull request. Flag actions that are not pinned and `run:` steps that interpolate `github.event` fields.
- A new runtime dependency in `annex_29.gemspec` or a `Gemfile` source other than the default registry.

## Known false-positives

- `lib/annex_29/word_segmentation.rb` is generated by Ragel and is excluded from the scan. Review the grammar in `word_segmentation.rl.erb` instead. Its state tables and jump code are generator output.
- `ERB.new(template).result` in the `Rakefile` renders a template that lives in the repository, from the property files in `data/`. It never sees caller input.
- The `Regexp` objects in the template (`property_regex`, `general_category_regex`) run only at build time over the `data/` files. They are not applied to text from callers.
- `sh("ragel", ...)` in the `Rakefile` passes fixed arguments and uses no shell string.
- `%x(git ls-files -z)` in `annex_29.gemspec` is the usual way to list gem files and uses no input.
- `spec/` reads `data/WordBreakTest.txt` and builds strings from code points on purpose. Those are conformance tests, and they are not production code.
- `Annex29.segment_words` returns what the caller passed in, cut into pieces. That is the purpose of the gem and is not a data leak.

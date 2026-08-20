# Changelog

## [1.7.0](https://github.com/rphlmr/codex/compare/v1.6.2...v1.7.0) (2026-08-20)


### Features

* **future-architect:** add canonical progressive-disclosure reviews ([8b112cb](https://github.com/rphlmr/codex/commit/8b112cb3333443606c87bea522ce8cbf53c9fd83))
* **sol-verifier:** add traceable canonical verification reports ([8b112cb](https://github.com/rphlmr/codex/commit/8b112cb3333443606c87bea522ce8cbf53c9fd83))

## [1.6.2](https://github.com/rphlmr/codex/compare/v1.6.1...v1.6.2) (2026-08-19)


### Bug Fixes

* **config:** remove unsupported env test read override ([5d8e4c0](https://github.com/rphlmr/codex/commit/5d8e4c022e64165334ed119acf846d61afe37848))

## [1.6.1](https://github.com/rphlmr/codex/compare/v1.6.0...v1.6.1) (2026-08-19)


### Bug Fixes

* **config:** allow reading test environment files ([061d379](https://github.com/rphlmr/codex/commit/061d379694d86ba92b112940ce6bfb5f185a6cab))
* **config:** stop overriding the system temporary directory ([061d379](https://github.com/rphlmr/codex/commit/061d379694d86ba92b112940ce6bfb5f185a6cab))

## [1.6.0](https://github.com/rphlmr/codex/compare/v1.5.0...v1.6.0) (2026-08-19)


### Features

* **config:** allow local binding in workspace-safe network permissions ([453c9bf](https://github.com/rphlmr/codex/commit/453c9bf6fbc444abb22cdd5b4693ca65342cce1e))

## [1.5.0](https://github.com/rphlmr/codex/compare/v1.4.0...v1.5.0) (2026-08-19)


### Features

* **workflows:** route contract-heavy plans to Sol ([d673908](https://github.com/rphlmr/codex/commit/d6739081f6ee4e0318eb3f4d18280f22e5a243a6))


### Bug Fixes

* **verification:** sanitize legacy package-manager proxy variables ([d673908](https://github.com/rphlmr/codex/commit/d6739081f6ee4e0318eb3f4d18280f22e5a243a6))

## [1.4.0](https://github.com/rphlmr/codex/compare/v1.3.0...v1.4.0) (2026-08-19)


### Features

* **config:** add consent-first configuration updater ([ce39858](https://github.com/rphlmr/codex/commit/ce3985896cf4dc8fea57ab6462c398fd98a341d2))


### Bug Fixes

* **agents:** isolate specialized agent workflows ([a02a407](https://github.com/rphlmr/codex/commit/a02a407bcad5f0b245da08e84e3689157bbd03f3))

## [1.3.0](https://github.com/rphlmr/codex/compare/v1.2.1...v1.3.0) (2026-08-18)


### Features

* **skills:** add plan finalization and session handoff workflows ([b618ffa](https://github.com/rphlmr/codex/commit/b618ffaef4ed7be78070f80cc6bbf4fa3a0cd358))


### Bug Fixes

* **agents:** enforce explicit validation and public API boundaries ([b618ffa](https://github.com/rphlmr/codex/commit/b618ffaef4ed7be78070f80cc6bbf4fa3a0cd358))
* **commit-message:** identify breaking staged changes ([b618ffa](https://github.com/rphlmr/codex/commit/b618ffaef4ed7be78070f80cc6bbf4fa3a0cd358))
* **pr-changelog:** disclose inferred comparison targets ([b618ffa](https://github.com/rphlmr/codex/commit/b618ffaef4ed7be78070f80cc6bbf4fa3a0cd358))
* **skills:** require explicit workflow invocation ([b618ffa](https://github.com/rphlmr/codex/commit/b618ffaef4ed7be78070f80cc6bbf4fa3a0cd358))

## [1.2.1](https://github.com/rphlmr/codex/compare/v1.2.0...v1.2.1) (2026-08-18)


### Bug Fixes

* **agents:** sanitize legacy no-proxy package manager settings ([a0aed96](https://github.com/rphlmr/codex/commit/a0aed9628da5d77e72b6b8fa001b2b3eb69e0dea))
* **architecture:** present concise independent review summaries ([a0aed96](https://github.com/rphlmr/codex/commit/a0aed9628da5d77e72b6b8fa001b2b3eb69e0dea))
* **verification:** preserve findings in concise result digests ([a0aed96](https://github.com/rphlmr/codex/commit/a0aed9628da5d77e72b6b8fa001b2b3eb69e0dea))

## [1.2.0](https://github.com/rphlmr/codex/compare/v1.1.0...v1.2.0) (2026-08-17)


### Features

* **agents:** enforce authoritative sol implementation briefs ([ae4cd69](https://github.com/rphlmr/codex/commit/ae4cd69b243bf7e9df36159b53d0b7280dc4ebbc))
* **planning:** define executable plan contracts ([4c18a58](https://github.com/rphlmr/codex/commit/4c18a58f6ba3b84318390a37df1de1562b23e1a9))


### Bug Fixes

* **implement-plan:** preserve only explicitly approved validation ([4c18a58](https://github.com/rphlmr/codex/commit/4c18a58f6ba3b84318390a37df1de1562b23e1a9))
* **implement-plan:** reject incomplete approved plans ([4c18a58](https://github.com/rphlmr/codex/commit/4c18a58f6ba3b84318390a37df1de1562b23e1a9))

## [1.1.0](https://github.com/rphlmr/codex/compare/v1.0.0...v1.1.0) (2026-08-17)


### Features

* **docs:** document runtime download domains ([6e8884d](https://github.com/rphlmr/codex/commit/6e8884d20c948ef2cccde3551d4b47a03390ff23))

## 1.0.0 (2026-08-17)


### ⚠ BREAKING CHANGES

* **agents:** remove the Luna fast and Terra implementer agents and the implement-plan-fast skill; use the standard implement-plan workflow instead

### Features

* **agents:** strengthen specialized agent workflows ([0944d13](https://github.com/rphlmr/codex/commit/0944d13db695cdb04d9dddc4277d0b17b372d197))
* **release:** automate versioning and releases ([0944d13](https://github.com/rphlmr/codex/commit/0944d13db695cdb04d9dddc4277d0b17b372d197))
* **skills:** enforce delegated workflow contracts ([0944d13](https://github.com/rphlmr/codex/commit/0944d13db695cdb04d9dddc4277d0b17b372d197))


### Bug Fixes

* **sync:** make the agent sync script executable ([0944d13](https://github.com/rphlmr/codex/commit/0944d13db695cdb04d9dddc4277d0b17b372d197))


### Code Refactoring

* **agents:** consolidate implementation workflows ([0944d13](https://github.com/rphlmr/codex/commit/0944d13db695cdb04d9dddc4277d0b17b372d197))

## Changelog

Release Please generates this file from Conventional Commits merged into `main`.

# Change Log

## [0.10.6](https://github.com/chef/train/tree/0.10.6) (2016-04-20)
[Full Changelog](https://github.com/chef/train/compare/v0.10.5...0.10.6)

**Merged pull requests:**

- add -L to get stat for symlink [\#85](https://github.com/chef/train/pull/85) ([vjeffrey](https://github.com/vjeffrey))
- release via travis + test via rubygems [\#84](https://github.com/chef/train/pull/84) ([arlimus](https://github.com/arlimus))

## [v0.10.5](https://github.com/chef/train/tree/v0.10.5) (2016-04-18)
[Full Changelog](https://github.com/chef/train/compare/v0.10.4...v0.10.5)

**Merged pull requests:**

- 0.10.5 [\#83](https://github.com/chef/train/pull/83) ([srenatus](https://github.com/srenatus))
- detection for hp-ux machine [\#82](https://github.com/chef/train/pull/82) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

## [v0.10.4](https://github.com/chef/train/tree/v0.10.4) (2016-03-31)
[Full Changelog](https://github.com/chef/train/compare/v0.10.3...v0.10.4)

**Fixed bugs:**

- bugfix: do not use unix path escape for windows [\#79](https://github.com/chef/train/pull/79) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.10.4 [\#80](https://github.com/chef/train/pull/80) ([arlimus](https://github.com/arlimus))

## [v0.10.3](https://github.com/chef/train/tree/v0.10.3) (2016-03-07)
[Full Changelog](https://github.com/chef/train/compare/v0.10.1...v0.10.3)

**Fixed bugs:**

- set default value for ssh compression to false [\#77](https://github.com/chef/train/pull/77) ([chris-rock](https://github.com/chris-rock))
- avoid mock backend error on nil commands [\#75](https://github.com/chef/train/pull/75) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- 0.10.3 [\#78](https://github.com/chef/train/pull/78) ([chris-rock](https://github.com/chris-rock))
- 0.10.2 [\#76](https://github.com/chef/train/pull/76) ([arlimus](https://github.com/arlimus))

## [v0.10.1](https://github.com/chef/train/tree/v0.10.1) (2016-02-29)
[Full Changelog](https://github.com/chef/train/compare/v0.10.0...v0.10.1)

**Merged pull requests:**

- 0.10.1 [\#74](https://github.com/chef/train/pull/74) ([chris-rock](https://github.com/chris-rock))
- fix gem build license warning [\#73](https://github.com/chef/train/pull/73) ([chris-rock](https://github.com/chris-rock))
- depend on docker-api 1.26.2 [\#72](https://github.com/chef/train/pull/72) ([someara](https://github.com/someara))

## [v0.10.0](https://github.com/chef/train/tree/v0.10.0) (2016-02-19)
[Full Changelog](https://github.com/chef/train/compare/v0.9.7...v0.10.0)

**Implemented enhancements:**

- show mock failures for commands [\#69](https://github.com/chef/train/pull/69) ([arlimus](https://github.com/arlimus))
- update gems and rubocop [\#68](https://github.com/chef/train/pull/68) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- complete rewrite of windows version detection [\#70](https://github.com/chef/train/pull/70) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.10.0 [\#71](https://github.com/chef/train/pull/71) ([chris-rock](https://github.com/chris-rock))

## [v0.9.7](https://github.com/chef/train/tree/v0.9.7) (2016-02-05)
[Full Changelog](https://github.com/chef/train/compare/v0.9.6...v0.9.7)

**Implemented enhancements:**

- feature: add file.basename [\#64](https://github.com/chef/train/pull/64) ([arlimus](https://github.com/arlimus))
- add `requiretty` workaround measures [\#63](https://github.com/chef/train/pull/63) ([srenatus](https://github.com/srenatus))

**Fixed bugs:**

- ensure bundler is installed on travis [\#66](https://github.com/chef/train/pull/66) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.7 [\#67](https://github.com/chef/train/pull/67) ([chris-rock](https://github.com/chris-rock))

## [v0.9.6](https://github.com/chef/train/tree/v0.9.6) (2016-01-29)
[Full Changelog](https://github.com/chef/train/compare/v0.9.5...v0.9.6)

**Implemented enhancements:**

- add solaris support [\#61](https://github.com/chef/train/pull/61) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.6 [\#62](https://github.com/chef/train/pull/62) ([chris-rock](https://github.com/chris-rock))

## [v0.9.5](https://github.com/chef/train/tree/v0.9.5) (2016-01-25)
[Full Changelog](https://github.com/chef/train/compare/v0.9.4...v0.9.5)

**Implemented enhancements:**

- use minitest for windows tests [\#56](https://github.com/chef/train/pull/56) ([chris-rock](https://github.com/chris-rock))
- use negotiate auth for winrm and not basic\_auth [\#55](https://github.com/chef/train/pull/55) ([mwrock](https://github.com/mwrock))
- bugfix: pin net-ssh 2.9 in gem file [\#54](https://github.com/chef/train/pull/54) ([chris-rock](https://github.com/chris-rock))
- Add appveyor and Windows test [\#53](https://github.com/chef/train/pull/53) ([chris-rock](https://github.com/chris-rock))
- Deprecating winrm-tansport gem [\#46](https://github.com/chef/train/pull/46) ([mwrock](https://github.com/mwrock))

**Fixed bugs:**

- Cannot install train on Windows with ChefDK if username \>9 chars in length due to spec filename lengths in docker-api gem. [\#28](https://github.com/chef/train/issues/28)
- Properly wrap commands in powershell for local backend [\#57](https://github.com/chef/train/pull/57) ([chris-rock](https://github.com/chris-rock))
- Copying https://github.com/test-kitchen/test-kitchen/pull/919 to this repo [\#52](https://github.com/chef/train/pull/52) ([tyler-ball](https://github.com/tyler-ball))

**Merged pull requests:**

- 0.9.5 [\#58](https://github.com/chef/train/pull/58) ([chris-rock](https://github.com/chris-rock))

## [v0.9.4](https://github.com/chef/train/tree/v0.9.4) (2016-01-15)
[Full Changelog](https://github.com/chef/train/compare/v0.9.3...v0.9.4)

**Implemented enhancements:**

- 0.9.3 is empty on Windows [\#48](https://github.com/chef/train/pull/48) ([tyler-ball](https://github.com/tyler-ball))
- Updating to the latest release of net-ssh to consume https://github.com/net-ssh/net-ssh/pull/280 [\#47](https://github.com/chef/train/pull/47) ([tyler-ball](https://github.com/tyler-ball))

**Fixed bugs:**

- bugfix: command wrapper always return nil [\#50](https://github.com/chef/train/pull/50) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.4 [\#51](https://github.com/chef/train/pull/51) ([chris-rock](https://github.com/chris-rock))

## [v0.9.3](https://github.com/chef/train/tree/v0.9.3) (2016-01-03)
[Full Changelog](https://github.com/chef/train/compare/v0.9.2...v0.9.3)

**Implemented enhancements:**

- introduce `mounted` as a separate method to retrieve the content [\#44](https://github.com/chef/train/pull/44) ([chris-rock](https://github.com/chris-rock))
- Support for local transport on Windows [\#43](https://github.com/chef/train/pull/43) ([chris-rock](https://github.com/chris-rock))
- Split integration test preparation from executing [\#42](https://github.com/chef/train/pull/42) ([chris-rock](https://github.com/chris-rock))
- Support for AIX and targeted SSH testing [\#41](https://github.com/chef/train/pull/41) ([foobarbam](https://github.com/foobarbam))

**Merged pull requests:**

- 0.9.3 [\#45](https://github.com/chef/train/pull/45) ([chris-rock](https://github.com/chris-rock))

## [v0.9.2](https://github.com/chef/train/tree/v0.9.2) (2015-12-11)
[Full Changelog](https://github.com/chef/train/compare/v0.9.1...v0.9.2)

**Implemented enhancements:**

- add changelog [\#38](https://github.com/chef/train/pull/38) ([chris-rock](https://github.com/chris-rock))
- activate integration tests in travis [\#37](https://github.com/chef/train/pull/37) ([chris-rock](https://github.com/chris-rock))
- Adding support for Wind River Linux in support of Cisco devices [\#33](https://github.com/chef/train/pull/33) ([adamleff](https://github.com/adamleff))

**Fixed bugs:**

- Integration test failures [\#34](https://github.com/chef/train/issues/34)
- Implemented WindowsFile\#exist? [\#36](https://github.com/chef/train/pull/36) ([docwhat](https://github.com/docwhat))
- adapt integration test to changes in command\_wrapper [\#35](https://github.com/chef/train/pull/35) ([srenatus](https://github.com/srenatus))

**Closed issues:**

- WinRM plaintext transport is hardcoded \(cannot use SSL\) [\#29](https://github.com/chef/train/issues/29)

**Merged pull requests:**

- 0.9.2 [\#40](https://github.com/chef/train/pull/40) ([arlimus](https://github.com/arlimus))
- add rake version helpers [\#39](https://github.com/chef/train/pull/39) ([arlimus](https://github.com/arlimus))

## [v0.9.1](https://github.com/chef/train/tree/v0.9.1) (2015-11-03)
[Full Changelog](https://github.com/chef/train/compare/0.9.0...v0.9.1)

**Implemented enhancements:**

- R train [\#27](https://github.com/chef/train/pull/27) ([arlimus](https://github.com/arlimus))
- Update style of readme [\#26](https://github.com/chef/train/pull/26) ([chris-rock](https://github.com/chris-rock))
- Add Apache 2.0 License [\#25](https://github.com/chef/train/pull/25) ([jamesc](https://github.com/jamesc))

## [0.9.0](https://github.com/chef/train/tree/0.9.0) (2015-11-03)
**Implemented enhancements:**

- set windows name in :release [\#23](https://github.com/chef/train/pull/23) ([arlimus](https://github.com/arlimus))
- basic file transport via winrm [\#21](https://github.com/chef/train/pull/21) ([chris-rock](https://github.com/chris-rock))
- dont return nil on command errors stdout/stderr [\#20](https://github.com/chef/train/pull/20) ([arlimus](https://github.com/arlimus))
- skip .delivery in gemspec [\#19](https://github.com/chef/train/pull/19) ([arlimus](https://github.com/arlimus))
- Verify sudo is working and fail with error messages if it isn't [\#18](https://github.com/chef/train/pull/18) ([arlimus](https://github.com/arlimus))
- improve file eposure [\#16](https://github.com/chef/train/pull/16) ([chris-rock](https://github.com/chris-rock))
- add delivery [\#13](https://github.com/chef/train/pull/13) ([arlimus](https://github.com/arlimus))
- Sudo [\#12](https://github.com/chef/train/pull/12) ([arlimus](https://github.com/arlimus))
- Extract options handling for transport [\#11](https://github.com/chef/train/pull/11) ([arlimus](https://github.com/arlimus))
- don't let mock commands return nil on stdout or stderr [\#10](https://github.com/chef/train/pull/10) ([arlimus](https://github.com/arlimus))
- allow mock command to support sha256 mocking of commands [\#9](https://github.com/chef/train/pull/9) ([arlimus](https://github.com/arlimus))
- register plugins with both names and symbols [\#8](https://github.com/chef/train/pull/8) ([arlimus](https://github.com/arlimus))
- split of mock into transport and connection [\#7](https://github.com/chef/train/pull/7) ([arlimus](https://github.com/arlimus))
- bugfix: add docker dependency to gemspec [\#6](https://github.com/chef/train/pull/6) ([arlimus](https://github.com/arlimus))
- move train/plugins/common to train/extras [\#2](https://github.com/chef/train/pull/2) ([arlimus](https://github.com/arlimus))
- add Travis [\#1](https://github.com/chef/train/pull/1) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- bugfix: prevent debugging info to stdout on winrm [\#22](https://github.com/chef/train/pull/22) ([arlimus](https://github.com/arlimus))
- bugfix: fail ssh connections correctly [\#17](https://github.com/chef/train/pull/17) ([arlimus](https://github.com/arlimus))
- bugfix: initialize mock transport to correct family [\#14](https://github.com/chef/train/pull/14) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- bump train version to 0.9.0 [\#24](https://github.com/chef/train/pull/24) ([chris-rock](https://github.com/chris-rock))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
<!-- latest_release 1.6.0 -->
## [v1.6.0](https://github.com/inspec/train/tree/v1.6.0) (2018-12-19)

#### Merged Pull Requests
- Expose additional winrm options [#392](https://github.com/inspec/train/pull/392) ([frezbo](https://github.com/frezbo))
<!-- latest_release -->

<!-- release_rollup since=1.5.11 -->
### Changes since 1.5.11 release

#### Merged Pull Requests
- Expose additional winrm options [#392](https://github.com/inspec/train/pull/392) ([frezbo](https://github.com/frezbo)) <!-- 1.6.0 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v1.5.11](https://github.com/inspec/train/tree/v1.5.11) (2018-12-10)

#### Merged Pull Requests
- Add Google API application info [#378](https://github.com/inspec/train/pull/378) ([nathenharvey](https://github.com/nathenharvey))
- Fix shallow_link_path on remote unix [#373](https://github.com/inspec/train/pull/373) ([mheiges](https://github.com/mheiges))
- Remove `#local?` [#365](https://github.com/inspec/train/pull/365) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Added a new matcher for amazon linux 2 [#380](https://github.com/inspec/train/pull/380) ([artyomtkachenko](https://github.com/artyomtkachenko))
- Pass logger to Cisco IOS transport [#381](https://github.com/inspec/train/pull/381) ([btm](https://github.com/btm))
<!-- latest_stable_release -->

## [v1.5.6](https://github.com/inspec/train/tree/v1.5.6) (2018-11-01)

#### Merged Pull Requests
- Fix Cisco IOS detection when banners lack a `\r\n` [#372](https://github.com/inspec/train/pull/372) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Adds cached_client method in BaseConnection [#371](https://github.com/inspec/train/pull/371) ([dmccown](https://github.com/dmccown))

## [v1.5.4](https://github.com/inspec/train/tree/v1.5.4) (2018-10-18)

#### Merged Pull Requests
- Fixes the link pointing back to the plugin docs [#362](https://github.com/inspec/train/pull/362) ([cattywampus](https://github.com/cattywampus))
- Remove the legacy version bumping from the rakefile [#359](https://github.com/inspec/train/pull/359) ([tas50](https://github.com/tas50))
- Adds Azure Vault Client [#351](https://github.com/inspec/train/pull/351) ([r-fennell](https://github.com/r-fennell))
- Correct example plugin link [#363](https://github.com/inspec/train/pull/363) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v1.5.0](https://github.com/inspec/train/tree/v1.5.0) (2018-09-27)

#### Merged Pull Requests
- Update google-api-client version. [#348](https://github.com/inspec/train/pull/348) ([skpaterson](https://github.com/skpaterson))
- Adding GCP admin_client helper. [#349](https://github.com/inspec/train/pull/349) ([skpaterson](https://github.com/skpaterson))
- Plugins:  Test harness, test fixture, docs, and local-type example [#356](https://github.com/inspec/train/pull/356) ([clintoncwolfe](https://github.com/clintoncwolfe))
- Bump minor version. [#357](https://github.com/inspec/train/pull/357) ([jquick](https://github.com/jquick))

## [v1.4.37](https://github.com/inspec/train/tree/v1.4.37) (2018-09-13)

#### Merged Pull Requests
- Rescues SystemCallError instead of Errno [#346](https://github.com/inspec/train/pull/346) ([dmccown](https://github.com/dmccown))
- Add a export method for platforms [#347](https://github.com/inspec/train/pull/347) ([jquick](https://github.com/jquick))

## [v1.4.35](https://github.com/inspec/train/tree/v1.4.35) (2018-08-23)

#### Merged Pull Requests
- Ensure unique_identifier returns something meaningful for service acc… [#338](https://github.com/inspec/train/pull/338) ([skpaterson](https://github.com/skpaterson))
- Modify Cisco UUID detection to use processor ID [#342](https://github.com/inspec/train/pull/342) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Fixes failing test when you have a cred file [#343](https://github.com/inspec/train/pull/343) ([dmccown](https://github.com/dmccown))
- Adds connection to Graph RBAC API  [#327](https://github.com/inspec/train/pull/327) ([r-fennell](https://github.com/r-fennell))

## [v1.4.31](https://github.com/inspec/train/tree/v1.4.31) (2018-08-17)

#### Merged Pull Requests
- Fixes an issue where the credential file was nil [#337](https://github.com/inspec/train/pull/337) ([dmccown](https://github.com/dmccown))
- Enable using rubygems as plugins [#335](https://github.com/inspec/train/pull/335) ([clintoncwolfe](https://github.com/clintoncwolfe))

## [v1.4.29](https://github.com/inspec/train/tree/v1.4.29) (2018-08-15)

#### Features & Enhancements
- Pulls file credentials parsing out of Azure class [#324](https://github.com/inspec/train/pull/324) ([dmccown](https://github.com/dmccown))

#### Merged Pull Requests
- Modify checksum logic to use system binaries [#251](https://github.com/inspec/train/pull/251) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Require Ruby 2.0 and allow net-ssh 5.0 [#334](https://github.com/inspec/train/pull/334) ([tas50](https://github.com/tas50))
- Add non_interactive support for SSH [#336](https://github.com/inspec/train/pull/336) ([marcparadise](https://github.com/marcparadise))

## [v1.4.25](https://github.com/inspec/train/tree/v1.4.25) (2018-08-01)

#### Merged Pull Requests
- Remove not needed google-cloud dependency (see #328) and correct GCP … [#329](https://github.com/inspec/train/pull/329) ([skpaterson](https://github.com/skpaterson))

## [v1.4.24](https://github.com/inspec/train/tree/v1.4.24) (2018-07-26)

#### Merged Pull Requests
- Add shallow_link_path to inspect symlink direct link [#309](https://github.com/inspec/train/pull/309) ([ColinHebert](https://github.com/ColinHebert))
- Retry SSH command on IOError (Cisco IOS specific) [#326](https://github.com/inspec/train/pull/326) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v1.4.22](https://github.com/inspec/train/tree/v1.4.22) (2018-07-16)

#### Merged Pull Requests
- Add VMware transport [#321](https://github.com/inspec/train/pull/321) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v1.4.21](https://github.com/inspec/train/tree/v1.4.21) (2018-07-05)

#### Merged Pull Requests
- Remove the delivery cookbook [#317](https://github.com/inspec/train/pull/317) ([tas50](https://github.com/tas50))
- Modify `WindowsPipeRunner` stderr to use String [#320](https://github.com/inspec/train/pull/320) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v1.4.19](https://github.com/inspec/train/tree/v1.4.19) (2018-06-29)

#### Merged Pull Requests
- Fix detection of amazon linux 2 [#312](https://github.com/inspec/train/pull/312) ([artem-sidorenko](https://github.com/artem-sidorenko))
- Adding proper bastion support [#310](https://github.com/inspec/train/pull/310) ([frezbo](https://github.com/frezbo))
- Remove github_changelog_generator [#313](https://github.com/inspec/train/pull/313) ([tas50](https://github.com/tas50))
- Remove the deploy config from Travis [#315](https://github.com/inspec/train/pull/315) ([tas50](https://github.com/tas50))

## [v1.4.15](https://github.com/inspec/train/tree/v1.4.15) (2018-06-14)

#### Merged Pull Requests
- Allow TrainError to provide a supplement reason [#303](https://github.com/inspec/train/pull/303) ([marcparadise](https://github.com/marcparadise))
- Adding Oneview to platform detection. [#307](https://github.com/inspec/train/pull/307) ([skpaterson](https://github.com/skpaterson))
- Add the mock transport to train-core [#308](https://github.com/inspec/train/pull/308) ([jquick](https://github.com/jquick))
- Don&#39;t double-escape paths [#306](https://github.com/inspec/train/pull/306) ([voroniys](https://github.com/voroniys))

## [v1.4.11](https://github.com/inspec/train/tree/v1.4.11) (2018-05-17)

#### Merged Pull Requests
- Add required env for azure shell msi headers [#302](https://github.com/inspec/train/pull/302) ([jquick](https://github.com/jquick))

## [v1.4.10](https://github.com/inspec/train/tree/v1.4.10) (2018-05-17)

#### Merged Pull Requests
- support sudo passwords for cisco [#301](https://github.com/inspec/train/pull/301) ([arlimus](https://github.com/arlimus))

## [v1.4.9](https://github.com/inspec/train/tree/v1.4.9) (2018-05-16)

#### Bug Fixes
- Allow nil password and www_form_encoded_password to work together. [#297](https://github.com/inspec/train/pull/297) ([marcparadise](https://github.com/marcparadise))

#### Merged Pull Requests
- Support encoded passwords in target url [#296](https://github.com/inspec/train/pull/296) ([marcparadise](https://github.com/marcparadise))
- Initial import of transport for GCP. [#283](https://github.com/inspec/train/pull/283) ([skpaterson](https://github.com/skpaterson))
- Change Cisco IOS transport log level to INFO [#298](https://github.com/inspec/train/pull/298) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Unpin google-protobuf now that we are building it as a gem [#300](https://github.com/inspec/train/pull/300) ([scotthain](https://github.com/scotthain))

## [v1.4.4](https://github.com/inspec/train/tree/v1.4.4) (2018-05-02)

#### Merged Pull Requests
- Enable expeditor release tasks [#294](https://github.com/inspec/train/pull/294) ([jquick](https://github.com/jquick))
- Split train into a core gem. [#293](https://github.com/inspec/train/pull/293) ([miah](https://github.com/miah))



# Change Log

## [1.4.2](https://github.com/inspec/train/tree/1.4.2) (2018-04-26)
[Full Changelog](https://github.com/inspec/train/compare/v1.4.1...1.4.2)

**Merged pull requests:**

- switched method of determining aws account id to STS [\#286](https://github.com/inspec/train/pull/286) ([tkrueger](https://github.com/tkrueger))

## [v1.4.1](https://github.com/inspec/train/tree/v1.4.1) (2018-04-19)
[Full Changelog](https://github.com/inspec/train/compare/v1.4.0...v1.4.1)

**Merged pull requests:**

- Release 1.4.1 [\#287](https://github.com/inspec/train/pull/287) ([jquick](https://github.com/jquick))
- Add UUID for Cisco IOS and Nexus devices [\#285](https://github.com/inspec/train/pull/285) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Add handling for privileged exec mode [\#284](https://github.com/inspec/train/pull/284) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v1.4.0](https://github.com/inspec/train/tree/v1.4.0) (2018-04-12)
[Full Changelog](https://github.com/inspec/train/compare/v1.3.0...v1.4.0)

**Closed issues:**

- Train reports directories with the archive bit set as files on the windows platform [\#274](https://github.com/inspec/train/issues/274)

**Merged pull requests:**

- Release 1.4.0 [\#282](https://github.com/inspec/train/pull/282) ([jquick](https://github.com/jquick))
- Add CloudLinux as a detected platform [\#281](https://github.com/inspec/train/pull/281) ([tarcinil](https://github.com/tarcinil))
- Move Cisco IOS connection under SSH transport [\#279](https://github.com/inspec/train/pull/279) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Initialize FileManager using '@service' [\#278](https://github.com/inspec/train/pull/278) ([marcparadise](https://github.com/marcparadise))
- small fix to make sure windows directories with the archive bit set a… [\#275](https://github.com/inspec/train/pull/275) ([devoptimist](https://github.com/devoptimist))

## [v1.3.0](https://github.com/inspec/train/tree/v1.3.0) (2018-03-29)
[Full Changelog](https://github.com/inspec/train/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Update errors to have a base type of Train::Error [\#273](https://github.com/inspec/train/pull/273) ([marcparadise](https://github.com/marcparadise))

**Closed issues:**

- RFC: Generate unique uuid for platforms [\#264](https://github.com/inspec/train/issues/264)

**Merged pull requests:**

- Release Train 1.3.0 [\#276](https://github.com/inspec/train/pull/276) ([jquick](https://github.com/jquick))
- Add MSI connection option for azure. [\#272](https://github.com/inspec/train/pull/272) ([jquick](https://github.com/jquick))
- Add transport for Cisco IOS [\#271](https://github.com/inspec/train/pull/271) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Add platform uuid information. [\#270](https://github.com/inspec/train/pull/270) ([jquick](https://github.com/jquick))

## [v1.2.0](https://github.com/inspec/train/tree/v1.2.0) (2018-03-15)
[Full Changelog](https://github.com/inspec/train/compare/v1.1.1...v1.2.0)

**Implemented enhancements:**

- Change error message to use `connection` [\#263](https://github.com/inspec/train/pull/263) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

**Closed issues:**

- Force 64bit powershell if using ruby32 on a 64bit os [\#265](https://github.com/inspec/train/issues/265)
- Master OS detect family [\#260](https://github.com/inspec/train/issues/260)

**Merged pull requests:**

- Release train 1.2.0 [\#269](https://github.com/inspec/train/pull/269) ([jquick](https://github.com/jquick))
- Force 64bit powershell for 32bit ruby running on 64bit windows [\#266](https://github.com/inspec/train/pull/266) ([jquick](https://github.com/jquick))
- support cisco ios xe [\#262](https://github.com/inspec/train/pull/262) ([arlimus](https://github.com/arlimus))
- Create a master OS family and refactor specifications [\#261](https://github.com/inspec/train/pull/261) ([jquick](https://github.com/jquick))
- Support for Brocade FOS-based SAN devices [\#254](https://github.com/inspec/train/pull/254) ([marcelhuth](https://github.com/marcelhuth))
- ProxyCommand support [\#227](https://github.com/inspec/train/pull/227) ([cbeckr](https://github.com/cbeckr))

## [v1.1.1](https://github.com/inspec/train/tree/v1.1.1) (2018-02-14)
[Full Changelog](https://github.com/inspec/train/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- Release train 1.1.1 [\#259](https://github.com/inspec/train/pull/259) ([jquick](https://github.com/jquick))
- Add api sdk versions as platform release [\#258](https://github.com/inspec/train/pull/258) ([jquick](https://github.com/jquick))
- Add plat helper methods to api direct platforms. [\#257](https://github.com/inspec/train/pull/257) ([jquick](https://github.com/jquick))

## [v1.1.0](https://github.com/inspec/train/tree/v1.1.0) (2018-02-08)
[Full Changelog](https://github.com/inspec/train/compare/v1.0.0...v1.1.0)

**Closed issues:**

- Add azure:// target [\#233](https://github.com/inspec/train/issues/233)

**Merged pull requests:**

- Release train 1.1.0 [\#255](https://github.com/inspec/train/pull/255) ([jquick](https://github.com/jquick))
- Add qnx platform support [\#253](https://github.com/inspec/train/pull/253) ([jquick](https://github.com/jquick))
- Add azure transport [\#250](https://github.com/inspec/train/pull/250) ([jquick](https://github.com/jquick))
- Fix AIX and QNX file support [\#249](https://github.com/inspec/train/pull/249) ([adamleff](https://github.com/adamleff))

## [v1.0.0](https://github.com/inspec/train/tree/v1.0.0) (2018-02-01)
[Full Changelog](https://github.com/inspec/train/compare/v0.32.0...v1.0.0)

**Closed issues:**

- Add aws:// target [\#229](https://github.com/inspec/train/issues/229)

**Merged pull requests:**

- Update version to 1.0.0 [\#248](https://github.com/inspec/train/pull/248) ([jquick](https://github.com/jquick))
- cisco nexus + ios12 [\#247](https://github.com/inspec/train/pull/247) ([arlimus](https://github.com/arlimus))
- Add a CONTRIBUTING.md to Train [\#245](https://github.com/inspec/train/pull/245) ([miah](https://github.com/miah))
- catch detect failing to parse json [\#243](https://github.com/inspec/train/pull/243) ([arlimus](https://github.com/arlimus))
- if ssh closes the session force it to reset and reopen [\#242](https://github.com/inspec/train/pull/242) ([arlimus](https://github.com/arlimus))
- Add AWS transport [\#239](https://github.com/inspec/train/pull/239) ([clintoncwolfe](https://github.com/clintoncwolfe))
- Fix detection of Scientific Linux [\#237](https://github.com/inspec/train/pull/237) ([schrd](https://github.com/schrd))

## [v0.32.0](https://github.com/inspec/train/tree/v0.32.0) (2018-01-04)
[Full Changelog](https://github.com/inspec/train/compare/v0.31.1...v0.32.0)

**Fixed bugs:**

- platform names should be lower case [\#191](https://github.com/inspec/train/issues/191)
- Return platform name that is lower case and underscored [\#228](https://github.com/inspec/train/pull/228) ([jquick](https://github.com/jquick))

**Merged pull requests:**

- Release 0.32.0 [\#232](https://github.com/inspec/train/pull/232) ([adamleff](https://github.com/adamleff))
- Set mock transport to use the platform instance variable [\#230](https://github.com/inspec/train/pull/230) ([jquick](https://github.com/jquick))

## [v0.31.1](https://github.com/inspec/train/tree/v0.31.1) (2017-12-06)
[Full Changelog](https://github.com/inspec/train/compare/v0.31.0...v0.31.1)

**Merged pull requests:**

- Release 0.31.1 [\#226](https://github.com/inspec/train/pull/226) ([adamleff](https://github.com/adamleff))
- Allow runner specifications for local connections [\#225](https://github.com/inspec/train/pull/225) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v0.31.0](https://github.com/inspec/train/tree/v0.31.0) (2017-12-05)
[Full Changelog](https://github.com/inspec/train/compare/v0.30.0...v0.31.0)

**Fixed bugs:**

- Add release detect for failback debian [\#223](https://github.com/inspec/train/pull/223) ([jquick](https://github.com/jquick))

**Merged pull requests:**

- Release 0.31.0 [\#224](https://github.com/inspec/train/pull/224) ([adamleff](https://github.com/adamleff))
- Use named pipe to decrease local Windows runtime [\#220](https://github.com/inspec/train/pull/220) ([jerryaldrichiii](https://github.com/jerryaldrichiii))

## [v0.30.0](https://github.com/inspec/train/tree/v0.30.0) (2017-12-04)
[Full Changelog](https://github.com/inspec/train/compare/v0.29.2...v0.30.0)

**Merged pull requests:**

- Release 0.30.0 [\#222](https://github.com/inspec/train/pull/222) ([adamleff](https://github.com/adamleff))
- Change the mock transport name to be 'mock' [\#221](https://github.com/inspec/train/pull/221) ([jquick](https://github.com/jquick))
- Enable caching on connections [\#214](https://github.com/inspec/train/pull/214) ([jquick](https://github.com/jquick))

## [v0.29.2](https://github.com/inspec/train/tree/v0.29.2) (2017-11-21)
[Full Changelog](https://github.com/inspec/train/compare/v0.29.1...v0.29.2)

**Fixed bugs:**

- Add unix\_mode\_mask method to Train::File::Local::Unix [\#215](https://github.com/inspec/train/pull/215) ([adamleff](https://github.com/adamleff))

**Merged pull requests:**

- Fix regressions in 0.29.1 [\#219](https://github.com/inspec/train/pull/219) ([adamleff](https://github.com/adamleff))
- Use the sanitized file path for remote linux files [\#218](https://github.com/inspec/train/pull/218) ([RoboticCheese](https://github.com/RoboticCheese))
- Remove bundler install during Appveyor tests [\#217](https://github.com/inspec/train/pull/217) ([adamleff](https://github.com/adamleff))
- Fix inspec mock tests [\#216](https://github.com/inspec/train/pull/216) ([jquick](https://github.com/jquick))
- Platform framework and detect DSL [\#209](https://github.com/inspec/train/pull/209) ([jquick](https://github.com/jquick))

## [v0.29.1](https://github.com/inspec/train/tree/v0.29.1) (2017-11-13)
[Full Changelog](https://github.com/inspec/train/compare/v0.29.0...v0.29.1)

**Merged pull requests:**

- Release 0.29.1 [\#213](https://github.com/inspec/train/pull/213) ([adamleff](https://github.com/adamleff))
- Allow for a nil value when mocking OS [\#212](https://github.com/inspec/train/pull/212) ([adamleff](https://github.com/adamleff))
- Ensure a `mounted?` method exists for all File classes, including Mock [\#211](https://github.com/inspec/train/pull/211) ([adamleff](https://github.com/adamleff))

## [v0.29.0](https://github.com/inspec/train/tree/v0.29.0) (2017-11-13)
[Full Changelog](https://github.com/inspec/train/compare/v0.28.0...v0.29.0)

**Merged pull requests:**

- Release 0.29.0 [\#210](https://github.com/inspec/train/pull/210) ([adamleff](https://github.com/adamleff))
- Reverting accidental push to master re: \#204 [\#208](https://github.com/inspec/train/pull/208) ([adamleff](https://github.com/adamleff))
- clearer error if no auth methods are available [\#207](https://github.com/inspec/train/pull/207) ([thommay](https://github.com/thommay))
- Build a complete mock OS object [\#206](https://github.com/inspec/train/pull/206) ([adamleff](https://github.com/adamleff))
- Platform framework and detect DSL [\#204](https://github.com/inspec/train/pull/204) ([jquick](https://github.com/jquick))
- add basic qnx support for train [\#203](https://github.com/inspec/train/pull/203) ([chris-rock](https://github.com/chris-rock))
- Add CODEOWNERS for train [\#202](https://github.com/inspec/train/pull/202) ([adamleff](https://github.com/adamleff))
- implement uploads and downloads for ssh and winrm [\#201](https://github.com/inspec/train/pull/201) ([thommay](https://github.com/thommay))
- \[MSYS-649\] Fix InSpec file size in Windows, refactor File classes [\#193](https://github.com/inspec/train/pull/193) ([Vasu1105](https://github.com/Vasu1105))

## [v0.28.0](https://github.com/inspec/train/tree/v0.28.0) (2017-09-25)
[Full Changelog](https://github.com/inspec/train/compare/v0.27.0...v0.28.0)

**Merged pull requests:**

- Release 0.28.0 [\#200](https://github.com/inspec/train/pull/200) ([adamleff](https://github.com/adamleff))
- Continue to support older net-ssh while fixing 4.2 deprecation [\#199](https://github.com/inspec/train/pull/199) ([adamleff](https://github.com/adamleff))

## [v0.27.0](https://github.com/inspec/train/tree/v0.27.0) (2017-09-25)
[Full Changelog](https://github.com/inspec/train/compare/v0.26.2...v0.27.0)

**Merged pull requests:**

- Release v0.27.0 [\#198](https://github.com/inspec/train/pull/198) ([adamleff](https://github.com/adamleff))
- Bump to net-ssh 4.2, fix bad net-ssh deprecation [\#197](https://github.com/inspec/train/pull/197) ([adamleff](https://github.com/adamleff))

## [v0.26.2](https://github.com/inspec/train/tree/v0.26.2) (2017-09-05)
[Full Changelog](https://github.com/inspec/train/compare/v0.26.1...v0.26.2)

**Merged pull requests:**

- Release 0.26.2 [\#195](https://github.com/inspec/train/pull/195) ([adamleff](https://github.com/adamleff))
- Fix inconsistent link\_path behavior [\#194](https://github.com/inspec/train/pull/194) ([adamleff](https://github.com/adamleff))

## [v0.26.1](https://github.com/inspec/train/tree/v0.26.1) (2017-08-14)
[Full Changelog](https://github.com/inspec/train/compare/v0.26.0...v0.26.1)

**Merged pull requests:**

- Release 0.26.1 [\#188](https://github.com/inspec/train/pull/188) ([adamleff](https://github.com/adamleff))
- Return non-zero exit code for unknown mock command [\#187](https://github.com/inspec/train/pull/187) ([chris-rock](https://github.com/chris-rock))

## [v0.26.0](https://github.com/inspec/train/tree/v0.26.0) (2017-08-10)
[Full Changelog](https://github.com/inspec/train/compare/v0.25.0...v0.26.0)

**Fixed bugs:**

- AIX operating system name is not detected properly [\#181](https://github.com/inspec/train/issues/181)

**Closed issues:**

- Add support for ssh-agent to ssh transport [\#129](https://github.com/inspec/train/issues/129)

**Merged pull requests:**

- Release v0.26.0 [\#186](https://github.com/inspec/train/pull/186) ([adamleff](https://github.com/adamleff))
- typo - should $g for group instead of doulbe $u [\#185](https://github.com/inspec/train/pull/185) ([aklyachkin](https://github.com/aklyachkin))
- update ruby requirements to 2.2 - 2.4 range [\#184](https://github.com/inspec/train/pull/184) ([arlimus](https://github.com/arlimus))
- detect operating system name for AIX [\#182](https://github.com/inspec/train/pull/182) ([chris-rock](https://github.com/chris-rock))

## [v0.25.0](https://github.com/inspec/train/tree/v0.25.0) (2017-06-15)
[Full Changelog](https://github.com/inspec/train/compare/v0.24.0...v0.25.0)

**Merged pull requests:**

- Fix CoreOS platform detection [\#180](https://github.com/inspec/train/pull/180) ([rarenerd](https://github.com/rarenerd))
- Remove autoloads in favor of eager loading [\#178](https://github.com/inspec/train/pull/178) ([Sharpie](https://github.com/Sharpie))
- Fixed IPv6 URI parsing [\#176](https://github.com/inspec/train/pull/176) ([zfjagann](https://github.com/zfjagann))

## [v0.24.0](https://github.com/inspec/train/tree/v0.24.0) (2017-05-30)
[Full Changelog](https://github.com/inspec/train/compare/v0.23.0...v0.24.0)

**Merged pull requests:**

- prevent sudo on localhost targets [\#179](https://github.com/inspec/train/pull/179) ([arlimus](https://github.com/arlimus))

## [v0.23.0](https://github.com/inspec/train/tree/v0.23.0) (2017-03-29)
[Full Changelog](https://github.com/inspec/train/compare/v0.22.1...v0.23.0)

**Merged pull requests:**

- Release 0.23.0 [\#173](https://github.com/inspec/train/pull/173) ([adamleff](https://github.com/adamleff))
- Fix Net::SSH warning when passing nil option values [\#172](https://github.com/inspec/train/pull/172) ([tylercloke](https://github.com/tylercloke))
- winrm: hide password [\#171](https://github.com/inspec/train/pull/171) ([crepetl](https://github.com/crepetl))

## [v0.22.1](https://github.com/inspec/train/tree/v0.22.1) (2017-01-17)
[Full Changelog](https://github.com/inspec/train/compare/v0.22.0...v0.22.1)

**Merged pull requests:**

- Release 0.22.1 [\#169](https://github.com/inspec/train/pull/169) ([tduffield](https://github.com/tduffield))
- Relax net-ssh dep to allow 4.0 [\#168](https://github.com/inspec/train/pull/168) ([tduffield](https://github.com/tduffield))
- Fix Oracle Linux detection [\#167](https://github.com/inspec/train/pull/167) ([carldjohnston](https://github.com/carldjohnston))
- Add support for parallels & virtuozzo linux [\#166](https://github.com/inspec/train/pull/166) ([jaxxstorm](https://github.com/jaxxstorm))

## [v0.22.0](https://github.com/inspec/train/tree/v0.22.0) (2016-11-29)
[Full Changelog](https://github.com/inspec/train/compare/v0.21.1...v0.22.0)

**Implemented enhancements:**

- Try to use ssh agent if no password or key files have been specified [\#165](https://github.com/inspec/train/pull/165) ([alexpop](https://github.com/alexpop))

**Merged pull requests:**

- Add openvms detection [\#159](https://github.com/inspec/train/pull/159) ([briandoodyie](https://github.com/briandoodyie))

## [v0.21.1](https://github.com/inspec/train/tree/v0.21.1) (2016-11-04)
[Full Changelog](https://github.com/inspec/train/compare/v0.21.0...v0.21.1)

**Closed issues:**

- detect\_arista\_eos raises exception against unix host [\#160](https://github.com/inspec/train/issues/160)

**Merged pull requests:**

- ensure the os detection works in pty mode [\#161](https://github.com/inspec/train/pull/161) ([chris-rock](https://github.com/chris-rock))

## [v0.21.0](https://github.com/inspec/train/tree/v0.21.0) (2016-11-04)
[Full Changelog](https://github.com/inspec/train/compare/v0.20.1...v0.21.0)

**Implemented enhancements:**

- Train doesn't create a login shell [\#148](https://github.com/inspec/train/issues/148)

**Merged pull requests:**

- Add detection for Arista EOS [\#158](https://github.com/inspec/train/pull/158) ([jerearista](https://github.com/jerearista))

## [v0.20.1](https://github.com/inspec/train/tree/v0.20.1) (2016-10-15)
[Full Changelog](https://github.com/inspec/train/compare/v0.20.0...v0.20.1)

**Fixed bugs:**

- support empty URIs [\#154](https://github.com/inspec/train/pull/154) ([arlimus](https://github.com/arlimus))

## [v0.20.0](https://github.com/inspec/train/tree/v0.20.0) (2016-09-21)
[Full Changelog](https://github.com/inspec/train/compare/v0.19.1...v0.20.0)

**Fixed bugs:**

- get `Preparing modules for first use.` when I use train on Windows [\#153](https://github.com/inspec/train/issues/153)

**Merged pull requests:**

- `Preparing modules for first use.` error message on Windows [\#152](https://github.com/inspec/train/pull/152) ([chris-rock](https://github.com/chris-rock))
- Convert `wmic` architecture to a normal standard [\#151](https://github.com/inspec/train/pull/151) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Login shell [\#149](https://github.com/inspec/train/pull/149) ([jonathanmorley](https://github.com/jonathanmorley))

## [v0.19.1](https://github.com/inspec/train/tree/v0.19.1) (2016-09-16)
[Full Changelog](https://github.com/inspec/train/compare/v0.19.0...v0.19.1)

**Implemented enhancements:**

- hostname property for WinRM::Connection [\#128](https://github.com/inspec/train/issues/128)
- Return hostname from WinRM::Connection same as SSH::Connection [\#150](https://github.com/inspec/train/pull/150) ([alexpop](https://github.com/alexpop))

## [v0.19.0](https://github.com/inspec/train/tree/v0.19.0) (2016-09-05)
[Full Changelog](https://github.com/inspec/train/compare/v0.18.0...v0.19.0)

**Fixed bugs:**

- use stat -c for alpine linux [\#146](https://github.com/inspec/train/pull/146) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- support ruby 2.2.1 [\#145](https://github.com/inspec/train/pull/145) ([chris-rock](https://github.com/chris-rock))
- Use winrm v2 implementation [\#122](https://github.com/inspec/train/pull/122) ([mwrock](https://github.com/mwrock))

## [v0.18.0](https://github.com/inspec/train/tree/v0.18.0) (2016-08-26)
[Full Changelog](https://github.com/inspec/train/compare/v0.17.0...v0.18.0)

**Merged pull requests:**

- Allow JSON 2.0 on Ruby 2.2 and above [\#144](https://github.com/inspec/train/pull/144) ([jkeiser](https://github.com/jkeiser))
- Enable Ruby 2.3 in Travis, make it default suite [\#143](https://github.com/inspec/train/pull/143) ([jkeiser](https://github.com/jkeiser))
- Add the darwin platform family [\#141](https://github.com/inspec/train/pull/141) ([tas50](https://github.com/tas50))
- update integration test dependencies [\#139](https://github.com/inspec/train/pull/139) ([tas50](https://github.com/tas50))
- Add badges to the readme [\#138](https://github.com/inspec/train/pull/138) ([tas50](https://github.com/tas50))
- use --decode on base64 command to maintain compatibility with Darwin. [\#137](https://github.com/inspec/train/pull/137) ([thomascate](https://github.com/thomascate))

## [v0.17.0](https://github.com/inspec/train/tree/v0.17.0) (2016-08-19)
[Full Changelog](https://github.com/inspec/train/compare/v0.16.0...v0.17.0)

**Implemented enhancements:**

- return owner for files on windows [\#132](https://github.com/inspec/train/pull/132) ([chris-rock](https://github.com/chris-rock))

**Closed issues:**

- prefix powershell commands with `$ProgressPreference = "SilentlyContinue"` [\#134](https://github.com/inspec/train/issues/134)

**Merged pull requests:**

- CI improvements [\#133](https://github.com/inspec/train/pull/133) ([chris-rock](https://github.com/chris-rock))
- Rescue EPIPE on connect in ssh transport [\#130](https://github.com/inspec/train/pull/130) ([stevendanna](https://github.com/stevendanna))

## [v0.16.0](https://github.com/inspec/train/tree/v0.16.0) (2016-08-08)
[Full Changelog](https://github.com/inspec/train/compare/v0.15.1...v0.16.0)

**Merged pull requests:**

- provide file\_version and product\_version for windows files [\#127](https://github.com/inspec/train/pull/127) ([chris-rock](https://github.com/chris-rock))
- Bring train platform data more in line with ohai's platform data [\#126](https://github.com/inspec/train/pull/126) ([stevendanna](https://github.com/stevendanna))

## [v0.15.1](https://github.com/inspec/train/tree/v0.15.1) (2016-07-11)
[Full Changelog](https://github.com/inspec/train/compare/v0.15.0...v0.15.1)

**Fixed bugs:**

- bugfix: higher mode bits on local connection [\#125](https://github.com/inspec/train/pull/125) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- Test ruby 2.1 instead of 1.9.3 and only launch one test group per travis/appveyor [\#123](https://github.com/inspec/train/pull/123) ([mwrock](https://github.com/mwrock))

## [v0.15.0](https://github.com/inspec/train/tree/v0.15.0) (2016-07-01)
[Full Changelog](https://github.com/inspec/train/compare/v0.14.2...v0.15.0)

**Implemented enhancements:**

- have net-ssh request a pty [\#60](https://github.com/inspec/train/issues/60)

**Merged pull requests:**

- Allow requesting a PTY [\#121](https://github.com/inspec/train/pull/121) ([srenatus](https://github.com/srenatus))

## [v0.14.2](https://github.com/inspec/train/tree/v0.14.2) (2016-06-28)
[Full Changelog](https://github.com/inspec/train/compare/v0.14.1...v0.14.2)

**Merged pull requests:**

- do not log password in ssh connection output [\#120](https://github.com/inspec/train/pull/120) ([marcparadise](https://github.com/marcparadise))

## [v0.14.1](https://github.com/inspec/train/tree/v0.14.1) (2016-06-27)
[Full Changelog](https://github.com/inspec/train/compare/v0.14.0...v0.14.1)

**Fixed bugs:**

- bugfix: add mock backend initialization [\#119](https://github.com/inspec/train/pull/119) ([arlimus](https://github.com/arlimus))

## [v0.14.0](https://github.com/inspec/train/tree/v0.14.0) (2016-06-27)
[Full Changelog](https://github.com/inspec/train/compare/v0.13.1...v0.14.0)

**Implemented enhancements:**

- json in and out for base connection [\#118](https://github.com/inspec/train/pull/118) ([arlimus](https://github.com/arlimus))
- ESX support [\#116](https://github.com/inspec/train/pull/116) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

**Fixed bugs:**

- sporadic appveyor failure on `winrm delete ...` [\#105](https://github.com/inspec/train/issues/105)
- bugfix: run frozen string commands via ssh [\#117](https://github.com/inspec/train/pull/117) ([arlimus](https://github.com/arlimus))

## [v0.13.1](https://github.com/inspec/train/tree/v0.13.1) (2016-06-16)
[Full Changelog](https://github.com/inspec/train/compare/v0.13.0...v0.13.1)

**Implemented enhancements:**

- use train as gem name. Thanks @halo [\#115](https://github.com/inspec/train/pull/115) ([chris-rock](https://github.com/chris-rock))

## [v0.13.0](https://github.com/inspec/train/tree/v0.13.0) (2016-06-16)
[Full Changelog](https://github.com/inspec/train/compare/v0.12.1...v0.13.0)

**Implemented enhancements:**

- provide uri-formatted information on all connections [\#113](https://github.com/inspec/train/pull/113) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- Authentication with SSH Server on OSX is failing [\#111](https://github.com/inspec/train/issues/111)

**Merged pull requests:**

- adding support for vmware's esx server [\#114](https://github.com/inspec/train/pull/114) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))
- add missing keyboard-interactive authentication method [\#112](https://github.com/inspec/train/pull/112) ([chris-rock](https://github.com/chris-rock))

## [v0.12.1](https://github.com/inspec/train/tree/v0.12.1) (2016-05-23)
[Full Changelog](https://github.com/inspec/train/compare/v0.12.0...v0.12.1)

**Fixed bugs:**

-  loosen restriction for docker api [\#109](https://github.com/inspec/train/pull/109) ([chris-rock](https://github.com/chris-rock))

**Closed issues:**

- docker-api conflict when using docker cookbook [\#108](https://github.com/inspec/train/issues/108)

## [v0.12.0](https://github.com/inspec/train/tree/v0.12.0) (2016-05-16)
[Full Changelog](https://github.com/inspec/train/compare/v0.11.4...v0.12.0)

**Merged pull requests:**

- Custom sudo command [\#107](https://github.com/inspec/train/pull/107) ([jeremymv2](https://github.com/jeremymv2))

## [v0.11.4](https://github.com/inspec/train/tree/v0.11.4) (2016-05-13)
[Full Changelog](https://github.com/inspec/train/compare/v0.11.3...v0.11.4)

**Fixed bugs:**

- mount resource incorrect matching [\#103](https://github.com/inspec/train/issues/103)
- Add a space to avoid matching partial paths [\#104](https://github.com/inspec/train/pull/104) ([alexpop](https://github.com/alexpop))
- Update README.md [\#102](https://github.com/inspec/train/pull/102) ([mcquin](https://github.com/mcquin))

**Merged pull requests:**

- 0.11.4 [\#106](https://github.com/inspec/train/pull/106) ([arlimus](https://github.com/arlimus))

## [v0.11.3](https://github.com/inspec/train/tree/v0.11.3) (2016-05-10)
[Full Changelog](https://github.com/inspec/train/compare/v0.11.2...v0.11.3)

**Fixed bugs:**

- appveyor fixing... [\#98](https://github.com/inspec/train/pull/98) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- fix: winrm https listener is not configured anymore in appveyor [\#100](https://github.com/inspec/train/pull/100) ([chris-rock](https://github.com/chris-rock))
- use aix stats implementation for hpux as well [\#99](https://github.com/inspec/train/pull/99) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

## [v0.11.2](https://github.com/inspec/train/tree/v0.11.2) (2016-04-29)
[Full Changelog](https://github.com/inspec/train/compare/v0.11.1...v0.11.2)

**Fixed bugs:**

- bugfix: windows file failed to initialize with new symlink handler [\#96](https://github.com/inspec/train/pull/96) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- 0.11.2 [\#97](https://github.com/inspec/train/pull/97) ([alexpop](https://github.com/alexpop))

## [v0.11.1](https://github.com/inspec/train/tree/v0.11.1) (2016-04-28)
[Full Changelog](https://github.com/inspec/train/compare/v0.11.0...v0.11.1)

**Fixed bugs:**

- fix nil file paths [\#94](https://github.com/inspec/train/pull/94) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- provide a source path for filecommon [\#95](https://github.com/inspec/train/pull/95) ([arlimus](https://github.com/arlimus))
- restructure docker tests to balance load between 2 runs [\#93](https://github.com/inspec/train/pull/93) ([arlimus](https://github.com/arlimus))

## [v0.11.0](https://github.com/inspec/train/tree/v0.11.0) (2016-04-28)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.8...v0.11.0)

**Implemented enhancements:**

- Overhault file\(...\) and stat\(...\); point to destination of symlinks [\#92](https://github.com/inspec/train/pull/92) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- validate the backend configuration [\#91](https://github.com/inspec/train/pull/91) ([arlimus](https://github.com/arlimus))

## [v0.10.8](https://github.com/inspec/train/tree/v0.10.8) (2016-04-25)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.7...v0.10.8)

**Implemented enhancements:**

- loose restriction for mixlib-shellout [\#89](https://github.com/inspec/train/pull/89) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- use gemspec for travis [\#90](https://github.com/inspec/train/pull/90) ([chris-rock](https://github.com/chris-rock))
- Don't strip off the second byte of the octal mode. [\#88](https://github.com/inspec/train/pull/88) ([justindossey](https://github.com/justindossey))

## [v0.10.7](https://github.com/inspec/train/tree/v0.10.7) (2016-04-21)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.6...v0.10.7)

**Merged pull requests:**

- 0.10.7 [\#87](https://github.com/inspec/train/pull/87) ([arlimus](https://github.com/arlimus))
- Revert "add -L to get stat for symlink" [\#86](https://github.com/inspec/train/pull/86) ([arlimus](https://github.com/arlimus))

## [v0.10.6](https://github.com/inspec/train/tree/v0.10.6) (2016-04-20)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.5...v0.10.6)

**Merged pull requests:**

- add -L to get stat for symlink [\#85](https://github.com/inspec/train/pull/85) ([vjeffrey](https://github.com/vjeffrey))
- release via travis + test via rubygems [\#84](https://github.com/inspec/train/pull/84) ([arlimus](https://github.com/arlimus))

## [v0.10.5](https://github.com/inspec/train/tree/v0.10.5) (2016-04-18)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.4...v0.10.5)

**Merged pull requests:**

- 0.10.5 [\#83](https://github.com/inspec/train/pull/83) ([srenatus](https://github.com/srenatus))
- detection for hp-ux machine [\#82](https://github.com/inspec/train/pull/82) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

## [v0.10.4](https://github.com/inspec/train/tree/v0.10.4) (2016-03-31)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.3...v0.10.4)

**Fixed bugs:**

- bugfix: do not use unix path escape for windows [\#79](https://github.com/inspec/train/pull/79) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.10.4 [\#80](https://github.com/inspec/train/pull/80) ([arlimus](https://github.com/arlimus))

## [v0.10.3](https://github.com/inspec/train/tree/v0.10.3) (2016-03-07)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.1...v0.10.3)

**Fixed bugs:**

- set default value for ssh compression to false [\#77](https://github.com/inspec/train/pull/77) ([chris-rock](https://github.com/chris-rock))
- avoid mock backend error on nil commands [\#75](https://github.com/inspec/train/pull/75) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- 0.10.3 [\#78](https://github.com/inspec/train/pull/78) ([chris-rock](https://github.com/chris-rock))
- 0.10.2 [\#76](https://github.com/inspec/train/pull/76) ([arlimus](https://github.com/arlimus))

## [v0.10.1](https://github.com/inspec/train/tree/v0.10.1) (2016-02-29)
[Full Changelog](https://github.com/inspec/train/compare/v0.10.0...v0.10.1)

**Merged pull requests:**

- 0.10.1 [\#74](https://github.com/inspec/train/pull/74) ([chris-rock](https://github.com/chris-rock))
- fix gem build license warning [\#73](https://github.com/inspec/train/pull/73) ([chris-rock](https://github.com/chris-rock))
- depend on docker-api 1.26.2 [\#72](https://github.com/inspec/train/pull/72) ([someara](https://github.com/someara))

## [v0.10.0](https://github.com/inspec/train/tree/v0.10.0) (2016-02-19)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.7...v0.10.0)

**Implemented enhancements:**

- show mock failures for commands [\#69](https://github.com/inspec/train/pull/69) ([arlimus](https://github.com/arlimus))
- update gems and rubocop [\#68](https://github.com/inspec/train/pull/68) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- complete rewrite of windows version detection [\#70](https://github.com/inspec/train/pull/70) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.10.0 [\#71](https://github.com/inspec/train/pull/71) ([chris-rock](https://github.com/chris-rock))

## [v0.9.7](https://github.com/inspec/train/tree/v0.9.7) (2016-02-05)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.6...v0.9.7)

**Implemented enhancements:**

- feature: add file.basename [\#64](https://github.com/inspec/train/pull/64) ([arlimus](https://github.com/arlimus))
- add `requiretty` workaround measures [\#63](https://github.com/inspec/train/pull/63) ([srenatus](https://github.com/srenatus))

**Fixed bugs:**

- ensure bundler is installed on travis [\#66](https://github.com/inspec/train/pull/66) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.7 [\#67](https://github.com/inspec/train/pull/67) ([chris-rock](https://github.com/chris-rock))

## [v0.9.6](https://github.com/inspec/train/tree/v0.9.6) (2016-01-29)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.5...v0.9.6)

**Implemented enhancements:**

- add solaris support [\#61](https://github.com/inspec/train/pull/61) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.6 [\#62](https://github.com/inspec/train/pull/62) ([chris-rock](https://github.com/chris-rock))

## [v0.9.5](https://github.com/inspec/train/tree/v0.9.5) (2016-01-25)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.4...v0.9.5)

**Implemented enhancements:**

- use minitest for windows tests [\#56](https://github.com/inspec/train/pull/56) ([chris-rock](https://github.com/chris-rock))
- use negotiate auth for winrm and not basic\_auth [\#55](https://github.com/inspec/train/pull/55) ([mwrock](https://github.com/mwrock))
- bugfix: pin net-ssh 2.9 in gem file [\#54](https://github.com/inspec/train/pull/54) ([chris-rock](https://github.com/chris-rock))
- Add appveyor and Windows test [\#53](https://github.com/inspec/train/pull/53) ([chris-rock](https://github.com/chris-rock))
- Deprecating winrm-tansport gem [\#46](https://github.com/inspec/train/pull/46) ([mwrock](https://github.com/mwrock))

**Fixed bugs:**

- Cannot install train on Windows with ChefDK if username \>9 chars in length due to spec filename lengths in docker-api gem. [\#28](https://github.com/inspec/train/issues/28)
- Properly wrap commands in powershell for local backend [\#57](https://github.com/inspec/train/pull/57) ([chris-rock](https://github.com/chris-rock))
- Copying https://github.com/test-kitchen/test-kitchen/pull/919 to this repo [\#52](https://github.com/inspec/train/pull/52) ([tyler-ball](https://github.com/tyler-ball))

**Merged pull requests:**

- 0.9.5 [\#58](https://github.com/inspec/train/pull/58) ([chris-rock](https://github.com/chris-rock))

## [v0.9.4](https://github.com/inspec/train/tree/v0.9.4) (2016-01-15)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.3...v0.9.4)

**Implemented enhancements:**

- 0.9.3 is empty on Windows [\#48](https://github.com/inspec/train/pull/48) ([tyler-ball](https://github.com/tyler-ball))
- Updating to the latest release of net-ssh to consume https://github.com/net-ssh/net-ssh/pull/280 [\#47](https://github.com/inspec/train/pull/47) ([tyler-ball](https://github.com/tyler-ball))

**Fixed bugs:**

- bugfix: command wrapper always return nil [\#50](https://github.com/inspec/train/pull/50) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.4 [\#51](https://github.com/inspec/train/pull/51) ([chris-rock](https://github.com/chris-rock))

## [v0.9.3](https://github.com/inspec/train/tree/v0.9.3) (2016-01-03)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.2...v0.9.3)

**Implemented enhancements:**

- introduce `mounted` as a separate method to retrieve the content [\#44](https://github.com/inspec/train/pull/44) ([chris-rock](https://github.com/chris-rock))
- Support for local transport on Windows [\#43](https://github.com/inspec/train/pull/43) ([chris-rock](https://github.com/chris-rock))
- Split integration test preparation from executing [\#42](https://github.com/inspec/train/pull/42) ([chris-rock](https://github.com/chris-rock))
- Support for AIX and targeted SSH testing [\#41](https://github.com/inspec/train/pull/41) ([foobarbam](https://github.com/foobarbam))

**Merged pull requests:**

- 0.9.3 [\#45](https://github.com/inspec/train/pull/45) ([chris-rock](https://github.com/chris-rock))

## [v0.9.2](https://github.com/inspec/train/tree/v0.9.2) (2015-12-11)
[Full Changelog](https://github.com/inspec/train/compare/v0.9.1...v0.9.2)

**Implemented enhancements:**

- add changelog [\#38](https://github.com/inspec/train/pull/38) ([chris-rock](https://github.com/chris-rock))
- activate integration tests in travis [\#37](https://github.com/inspec/train/pull/37) ([chris-rock](https://github.com/chris-rock))
- Adding support for Wind River Linux in support of Cisco devices [\#33](https://github.com/inspec/train/pull/33) ([adamleff](https://github.com/adamleff))

**Fixed bugs:**

- Integration test failures [\#34](https://github.com/inspec/train/issues/34)
- Implemented WindowsFile\#exist? [\#36](https://github.com/inspec/train/pull/36) ([docwhat](https://github.com/docwhat))
- adapt integration test to changes in command\_wrapper [\#35](https://github.com/inspec/train/pull/35) ([srenatus](https://github.com/srenatus))

**Closed issues:**

- WinRM plaintext transport is hardcoded \(cannot use SSL\) [\#29](https://github.com/inspec/train/issues/29)

**Merged pull requests:**

- 0.9.2 [\#40](https://github.com/inspec/train/pull/40) ([arlimus](https://github.com/arlimus))
- add rake version helpers [\#39](https://github.com/inspec/train/pull/39) ([arlimus](https://github.com/arlimus))

## [v0.9.1](https://github.com/inspec/train/tree/v0.9.1) (2015-11-03)
[Full Changelog](https://github.com/inspec/train/compare/0.9.0...v0.9.1)

**Implemented enhancements:**

- R train [\#27](https://github.com/inspec/train/pull/27) ([arlimus](https://github.com/arlimus))
- Update style of readme [\#26](https://github.com/inspec/train/pull/26) ([chris-rock](https://github.com/chris-rock))
- Add Apache 2.0 License [\#25](https://github.com/inspec/train/pull/25) ([jamesc](https://github.com/jamesc))

## [0.9.0](https://github.com/inspec/train/tree/0.9.0) (2015-11-03)
**Implemented enhancements:**

- set windows name in :release [\#23](https://github.com/inspec/train/pull/23) ([arlimus](https://github.com/arlimus))
- basic file transport via winrm [\#21](https://github.com/inspec/train/pull/21) ([chris-rock](https://github.com/chris-rock))
- dont return nil on command errors stdout/stderr [\#20](https://github.com/inspec/train/pull/20) ([arlimus](https://github.com/arlimus))
- skip .delivery in gemspec [\#19](https://github.com/inspec/train/pull/19) ([arlimus](https://github.com/arlimus))
- Verify sudo is working and fail with error messages if it isn't [\#18](https://github.com/inspec/train/pull/18) ([arlimus](https://github.com/arlimus))
- improve file eposure [\#16](https://github.com/inspec/train/pull/16) ([chris-rock](https://github.com/chris-rock))
- add delivery [\#13](https://github.com/inspec/train/pull/13) ([arlimus](https://github.com/arlimus))
- Sudo [\#12](https://github.com/inspec/train/pull/12) ([arlimus](https://github.com/arlimus))
- Extract options handling for transport [\#11](https://github.com/inspec/train/pull/11) ([arlimus](https://github.com/arlimus))
- don't let mock commands return nil on stdout or stderr [\#10](https://github.com/inspec/train/pull/10) ([arlimus](https://github.com/arlimus))
- allow mock command to support sha256 mocking of commands [\#9](https://github.com/inspec/train/pull/9) ([arlimus](https://github.com/arlimus))
- register plugins with both names and symbols [\#8](https://github.com/inspec/train/pull/8) ([arlimus](https://github.com/arlimus))
- split of mock into transport and connection [\#7](https://github.com/inspec/train/pull/7) ([arlimus](https://github.com/arlimus))
- bugfix: add docker dependency to gemspec [\#6](https://github.com/inspec/train/pull/6) ([arlimus](https://github.com/arlimus))
- move train/plugins/common to train/extras [\#2](https://github.com/inspec/train/pull/2) ([arlimus](https://github.com/arlimus))
- add Travis [\#1](https://github.com/inspec/train/pull/1) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- bugfix: prevent debugging info to stdout on winrm [\#22](https://github.com/inspec/train/pull/22) ([arlimus](https://github.com/arlimus))
- bugfix: fail ssh connections correctly [\#17](https://github.com/inspec/train/pull/17) ([arlimus](https://github.com/arlimus))
- bugfix: initialize mock transport to correct family [\#14](https://github.com/inspec/train/pull/14) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- bump train version to 0.9.0 [\#24](https://github.com/inspec/train/pull/24) ([chris-rock](https://github.com/chris-rock))
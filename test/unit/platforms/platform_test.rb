# encoding: utf-8

require 'helper'

describe 'platform' do
  def mock_platform(x)
    plat = Train::Platforms.name(x)
    plat.family_hierarchy = mock_os_hierarchy(plat).flatten
    plat.platform[:family] = plat.family_hierarchy[0]
    plat.add_platform_methods
    plat
  end

  def mock_platform_family(x)
    Train::Platforms.list[x] = nil if x == 'mock'
    plat = Train::Platforms.name(x).in_family(x)
    plat.family_hierarchy = mock_os_hierarchy(plat).flatten
    plat.platform[:family] = plat.family_hierarchy[0]
    plat.add_platform_methods
    plat
  end

  def mock_os_hierarchy(plat)
    plat.families.each_with_object([]) do |(k, _v), memo|
      memo << k.name
      memo << mock_os_hierarchy(k) unless k.families.empty?
    end
  end

  it 'set platform title' do
    plat = mock_platform_family('mock')
    plat.title.must_equal('Mock')
    plat.title('The Best Mock')
    plat.title.must_equal('The Best Mock')
  end

  it 'clean init name' do
    plat = mock_platform_family('Mo ck')
    plat.name.must_equal('mo_ck')
  end

  it 'set name and name override' do
    plat = mock_platform_family('mock')
    plat.name.must_equal('mock')
    plat[:name].must_equal('mock')
    plat.platform[:name] = 'Mock 2020'
    plat.add_platform_methods
    plat.name.must_equal('mock_2020')
    plat[:name].must_equal('mock_2020')
  end

  it 'check families' do
    plat = mock_platform_family('mock')
    plat.families.keys[0].name.must_equal('mock')
  end

  it 'check families with condition' do
    Train::Platforms.list['mock'] = nil
    plat = Train::Platforms.name('mock', arch: '= x86_64').in_family('linux')
    plat.families.keys[0].name.must_equal('linux')
    plat.families.values[0].must_equal({ arch: '= x86_64' })
  end

  it 'return direct families' do
    plat = mock_platform_family('mock')
    plat.in_family('mock2')
    plat.in_family('mock3')
    plat.direct_families.must_equal(["mock", "mock2", "mock3"])
  end

  it 'return to_hash' do
    plat = mock_platform_family('mock')
    plat.to_hash.must_equal({ family: "mock" })
  end

  it 'return unknown release' do
    plat = mock_platform_family('mock')
    plat[:release].must_equal('unknown')
  end

  it 'return name?' do
    plat = Train::Platforms.name('windows_rc1')
    defined?(plat.windows_rc1?).must_be_nil
    plat.add_platform_methods
    plat.windows_rc1?.must_equal(true)
  end

  it 'add platform methods' do
    Train::Platforms.list['mock'] = nil
    plat = Train::Platforms.name('mock').in_family('linux')
    defined?(plat.linux?).must_be_nil
    plat.family_hierarchy = mock_os_hierarchy(plat).flatten
    plat.add_platform_methods
    plat.linux?.must_equal(true)
  end

  it 'provides a method to access platform data' do
    family = 'test-os'
    os = mock_platform_family(family)
    os[:family].must_equal family
  end

  it 'provides an accessor for the full hash' do
    x = 'test-os'
    os = mock_platform_family(x)
    os.to_hash.must_equal({ family: x })
  end

  describe 'with platform set to redhat' do
    let(:os) { mock_platform('redhat') }
    it { os.redhat?.must_equal(true) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to oracle' do
    let(:os) { mock_platform('oracle') }
    it { os.redhat?.must_equal(true) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to centos' do
    let(:os) { mock_platform('centos') }
    it { os.redhat?.must_equal(true) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to fedora' do
    let(:os) { mock_platform('fedora') }
    it { os.fedora?.must_equal(true) }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to amazon' do
    let(:os) { mock_platform('amazon') }
    it { os.fedora?.must_equal(false) }
    it { os.redhat?.must_equal(true) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to debian' do
    let(:os) { mock_platform('debian') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(true) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to ubuntu' do
    let(:os) { mock_platform('ubuntu') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(true) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to linuxmint' do
    let(:os) { mock_platform('linuxmint') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(true) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to raspbian' do
    let(:os) { mock_platform('raspbian') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(true) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to suse' do
    let(:os) { mock_platform('suse') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(true) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to opensuse' do
    let(:os) { mock_platform('opensuse') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(true) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to alpine' do
    let(:os) { mock_platform('alpine') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to arch' do
    let(:os) { mock_platform('arch') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to coreos' do
    let(:os) { mock_platform('coreos') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to exherbo' do
    let(:os) { mock_platform('exherbo') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to gentoo' do
    let(:os) { mock_platform('gentoo') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to slackware' do
    let(:os) { mock_platform('slackware') }
    it { os.redhat?.must_equal(false) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to wrlinux' do
    let(:os) { mock_platform('wrlinux') }
    it { os.redhat?.must_equal(true) }
    it { os.debian?.must_equal(false) }
    it { os.suse?.must_equal(false) }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to linux' do
    let(:os) { mock_platform('linux') }
    it { os.linux?.must_equal(true) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to freebsd' do
    let(:os) { mock_platform('freebsd') }
    it { os.bsd?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to netbsd' do
    let(:os) { mock_platform('netbsd') }
    it { os.bsd?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to openbsd' do
    let(:os) { mock_platform('openbsd') }
    it { os.bsd?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to darwin' do
    let(:os) { mock_platform('darwin') }
    it { os.bsd?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to solaris' do
    let(:os) { mock_platform('solaris') }
    it { os.solaris?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to smartos' do
    let(:os) { mock_platform('smartos') }
    it { os.solaris?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to openindiana' do
    let(:os) { mock_platform('openindiana') }
    it { os.solaris?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to opensolaris' do
    let(:os) { mock_platform('opensolaris') }
    it { os.solaris?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to nexentacore' do
    let(:os) { mock_platform('nexentacore') }
    it { os.solaris?.must_equal(true) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
  end

  describe 'with platform set to windows' do
    let(:os) { mock_platform('windows') }
    it { os.solaris?.must_equal(false) }
    it { os.bsd?.must_equal(false) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(false) }
  end

  describe 'with platform set to hpux' do
    let(:os) { mock_platform('hpux') }
    it { os.solaris?.must_equal(false) }
    it { os.linux?.must_equal(false) }
    it { os.unix?.must_equal(true) }
    it { os.hpux?.must_equal(true) }
  end

  describe 'with platform set to esx' do
    let(:os) { mock_platform('vmkernel') }
    it { os.solaris?.must_equal(false) }
    it { os.linux?.must_equal(false) }
    it { os[:family].must_equal('esx') }
    it { os.unix?.must_equal(false) }
    it { os.esx?.must_equal(true) }
  end

  describe 'with platform set to darwin' do
    let(:os) { mock_platform('darwin') }
    it { os.solaris?.must_equal(false) }
    it { os.linux?.must_equal(false) }
    it { os[:family].must_equal('darwin') }
    it { os.bsd?.must_equal(true) }
    it { os.darwin?.must_equal(true) }
    it { os.unix?.must_equal(true) }
    it { os.bsd?.must_equal(true) }
    it { os.esx?.must_equal(false) }
  end

  describe 'with platform set to mac_os_x' do
    let(:os) { mock_platform('mac_os_x') }
    it { os.solaris?.must_equal(false) }
    it { os.linux?.must_equal(false) }
    it { os[:family].must_equal('darwin') }
    it { os.bsd?.must_equal(true) }
    it { os.darwin?.must_equal(true) }
    it { os.unix?.must_equal(true) }
    it { os.bsd?.must_equal(true) }
    it { os.esx?.must_equal(false) }
  end
end

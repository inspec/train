platform = Train::Platforms

# linux
platform.family('linux')
        .is_a('unix')
        .detect {
          puts @backend.run_command('uname -s').stdout
        }

# debian
platform.family('debian').is_a('linux')
platform.name('debian').title('Debian Linux').is_a('debian')
platform.name('ubuntu').is_a('debian').title('Ubuntu Linux')
platform.name('linuxmint').title('LinuxMint').is_a('debian').release('7.0')
platform.name('backtrack', release: '>= 4').is_a('debian')

# redhat
platform.family('redhat').is_a('linux')
platform.name('centos').title('Centos Linux').is_a('redhat')
platform.name('rhel').title('Red Hat Enterprise Linux').is_a('redhat')
platform.name('oracle').title('Oracle Linux').is_a('redhat')
platform.name('awz').title('Amazon Linux').is_a('redhat')

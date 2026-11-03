Name:		salt-vim
Version:	0.0.1
Release:	1%{?dist}
Summary:	Vim files for working on Salt files

Group:		Applications/Editors
License:	ASL 2.0
URL:		https://github.com/benatouba/salt-vim
Source0:	https://github.com/benatouba/salt-vim/archive/master.tar.gz

Requires:	vim >= 9.1

%description
Vim files for working on Salt files

%prep
%setup -q -n salt-vim-master

%build

%install
mkdir -p %{buildroot}%{_defaultlicensedir}/%{name}-%{version}
mkdir -p %{buildroot}%{_datarootdir}/vim/vimfiles/{syntax,ftdetect,ftplugin}
cp syntax/*.vim %{buildroot}%{_datarootdir}/vim/vimfiles/syntax/
cp ftdetect/sls.vim %{buildroot}%{_datarootdir}/vim/vimfiles/ftdetect/
cp ftplugin/*.vim %{buildroot}%{_datarootdir}/vim/vimfiles/ftplugin/
cp LICENSE %{buildroot}%{_defaultlicensedir}/%{name}-%{version}
cp NOTICE %{buildroot}%{_defaultlicensedir}/%{name}-%{version}

%files
%{_datarootdir}/vim/vimfiles/syntax/*.vim
%{_datarootdir}/vim/vimfiles/ftdetect/sls.vim
%{_datarootdir}/vim/vimfiles/ftplugin/*.vim
%{_defaultlicensedir}/%{name}-%{version}/LICENSE
%{_defaultlicensedir}/%{name}-%{version}/NOTICE
%doc



%changelog
* Mon Dec 19 2016 Kai Meyer <kai@gnukai.com> - 0.0.1-1
- Initial RPM spec


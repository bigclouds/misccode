Name:OpenStackVirtualRouter
Version: 1.0
Release: 1%{?dist}
Summary: tool to check and fix vr brain split	

Group: cn
License: GPLv2	
URL: 	cn.cn
Source0: osvr.tar

BuildRequires: python
Requires: python-libs python-psutil
#python-neutronclient python2-keystoneauth1

%description
%prep
%install
mkdir -p %{buildroot}/usr/bin
install %{_sourcedir}/osvr_check.py %{buildroot}/usr/bin
install %{_sourcedir}/nic.py %{buildroot}/usr/bin

%files
/usr/bin/osvr_check.py
/usr/bin/nic.py

%changelog


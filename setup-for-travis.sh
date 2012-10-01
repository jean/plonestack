#!/bin/sh

DEBIAN_VERSION=$(cat /etc/issue.net)

PACKAGING_TEAM=python24-team
PACKAGING_PPA=python24

case $DEBIAN_VERSION in
    'Ubuntu 9.10')
        DISTRO=karmic
        PACKAGING_TEAM=johncarr
        PACKAGING_PPA_KEY=1FD74F38E924D87C
        ;;
    'Ubuntu 10.04'*)
        DISTRO=lucid
        PACKAGING_PPA_KEY=16A0AA0B
        ;;
esac

cat > /etc/apt/sources.list.d/python24.list << HERE
deb http://ppa.launchpad.net/$PACKAGING_TEAM/$PACKAGING_PPA/ubuntu $DISTRO main 
deb-src http://ppa.launchpad.net/$PACKAGING_TEAM/$PACKAGING_PPA/ubuntu $DISTRO main
HERE

cat > /etc/apt/preferences.d/python24 << HERE
Package: *
Pin: release o=LP-PPA-$PACKAGING_TEAM-$PACKAGING_PPA
Pin-Priority: 1001
HERE

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $PACKAGING_PPA_KEY

apt-get update
apt-get install --force-yes -y -q python2.4 python-elementtree python-libxml2 python-lxml python-imaging python-ldap python-simplejson python-crypto python-setuptools xpdf wv build-essential python2.4-dev python2.6-dev varnish pound apache2 subversion


apt-get remove -y python-zc.buildout python-zc.lockfile

rm -rf /usr/local/lib/python2.6/dist-packages/zc.buildout-1.5.2-py2.6.egg
rm -rf /usr/local/lib/python2.4/site-packages/zc.buildout-1.5.2-py2.4.egg
rm -rf /usr/local/lib/python2.6/dist-packages/zc.buildout-1.4.3-py2.6.egg
rm -rf /usr/local/lib/python2.4/site-packages/zc.buildout-1.4.3-py2.4.egg


/etc/init.d/varnish stop
update-rc.d -f varnish remove
/etc/init.d/varnishlog stop
update-rc.d -f varnishlog remove

addgroup --system zope
adduser --system --home /var/local/sites --shell /bin/bash --ingroup zope --disabled-password --disabled-login zope

a2enmod ssl
a2enmod headers
a2enmod rewrite
a2enmod proxy_http

mkdir /var/log/zope
chown zope:zope /var/log/zope

mkdir /var/local/sites/www.foo.com
chown zope:zope /var/local/sites/www.foo.com

sudo locale-gen en_GB.UTF-8


==========
plonestack
==========

At Isotoma towers we have settled around a fairly standard buildout for
deploying Plone.

Inititally we copied and pasted this still evolving buildout between projects.
Backporting fixes to other sites was tedious, time consuming and error prone.
We switched to having the buildout on a HTTP server. However the lack of basic
auth support in buildout made this problematic for us. So we made "stacks" - a
special kind of buildout extension which allowed us to package our standard
buildout as eggs.

This is a 'stack' for deploying Plone on Ubuntu and Red Hat boxes.


Getting started
===============

Your buildout now looks like this::

    [buildout]
    extensions = plonestack
    versions = versions

    [versions]
    zc.buildout = 1.4.3
    Plone = 4.2.1


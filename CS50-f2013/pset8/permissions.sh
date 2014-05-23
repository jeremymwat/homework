#!/bin/sh

find . -type f | xargs chmod 644

find . -type d | xargs chmod 711

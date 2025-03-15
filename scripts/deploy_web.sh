#!/bin/sh
set -e
flutter build web
firebase deploy

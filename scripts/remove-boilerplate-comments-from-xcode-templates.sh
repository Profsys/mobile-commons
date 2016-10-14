#!/bin/bash
# Usage: 
# $ cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates
# $ bash ~/remove-boilerplate-comments-from-xcode-templates.sh
# Repeat for /Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates

find -E . -type f \
    \( -regex '.*\.[chm]' -or -regex '.*\.swift' \) \
    -exec sed -i '' '1,/^$/d' '{}' ';'
# https://gist.github.com/mx4492/81da9f3c363bc1c44f4e

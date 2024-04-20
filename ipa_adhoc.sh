if [ ! -n "$1" ] ;then
    flutter build ipa --export-options-plist=ios/adhocExportOptions.plist --no-tree-shake-icons
else
    flutter build ipa --build-number=$1 --export-options-plist=ios/adhocExportOptions.plist --no-tree-shake-icons
fi

mv build/ios/ipa/aila.ipa ~/Desktop/sidu_adhoc.ipa

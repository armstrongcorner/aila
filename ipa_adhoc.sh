flutter build ipa --build-number=$1 --export-options-plist=ios/adhocExportOptions.plist --no-tree-shake-icons
mv build/ios/ipa/aila.ipa ~/Desktop/aila_adhoc.ipa

flutter build ipa --build-number=$1 --export-options-plist=ios/appstoreExportOptions.plist --no-tree-shake-icons
mv build/ios/ipa/aila.ipa ~/Desktop/aila_appstore.ipa

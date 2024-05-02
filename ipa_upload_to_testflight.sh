if [ ! -n "$1" ] ;then
    flutter build ipa --export-options-plist=ios/appstoreExportOptions.plist --no-tree-shake-icons
else
    flutter build ipa --build-number=$1 --export-options-plist=ios/appstoreExportOptions.plist --no-tree-shake-icons
fi

mv build/ios/ipa/aila.ipa ~/Desktop/sidu_appstore.ipa

echo "Uploading to TestFlight..."
xcrun altool --upload-app --type ios -f ~/Desktop/sidu_appstore.ipa --apiKey 9Z7T433PM6 --apiIssuer 21962876-8727-4e44-9596-8a5c57f40a7a

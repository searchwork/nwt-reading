
avdmanager list

avdmanager create avd -n pixel_6_pro -k "system-images;android-31;google_apis_playstore;arm64-v8a" -d pixel_6_pro
avdmanager create avd -n foldable_8_in -k "system-images;android-31;google_apis_playstore;arm64-v8a" -d "8in Foldable"
avdmanager create avd -n tablet_7_in -k "system-images;android-31;google_apis_playstore;arm64-v8a" -d "7in WSVGA (Tablet)"

# The ratio is not accepted as 10" tablet screenshots in the Play Store.
# avdmanager create avd -n tablet_10_in -k "system-images;android-31;google_apis_playstore;arm64-v8a" -d "10.1in WXGA (Tablet)"
# Use this for the 10" tablet screenshots.
avdmanager create avd -n tablet_13_5_in -k "system-images;android-31;google_apis_playstore;arm64-v8a" -d "13.5in Freeform"


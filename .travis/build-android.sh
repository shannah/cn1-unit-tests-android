function finish() {
  kill $EMULATOR_PID
}
trap finish EXIT

wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip || exit 1
unzip -q platform-tools-latest-linux.zip -d ../ || exit 1
wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip || exit 1
unzip -q sdk-tools-linux-3859397.zip -d ../ || exit 1
echo yes | ../tools/bin/sdkmanager "tools" || exit 1
#echo yes | ../tools/bin/sdkmanager "platforms;android-25"
echo yes | ../tools/bin/sdkmanager "${ANDROID_PLATFORM}" || exit 1
#echo yes | ../tools/bin/sdkmanager "system-images;android-25;google_apis;armeabi-v7a"
echo yes | ../tools/bin/sdkmanager "${ANDROID_SYSTEM_IMAGE}" || exit 1
echo yes | ../tools/bin/sdkmanager "emulator" || exit 1
#echo no | ../tools/bin/avdmanager create avd -k "system-images;android-25;google_apis;armeabi-v7a" -n test -f --tag google_apis --abi armeabi-v7a
echo no | ../tools/bin/avdmanager create avd -k "${ANDROID_SYSTEM_IMAGE}" -n test -f --tag ${TAG} --abi ${ABI} || exit 1
../tools/emulator -avd test -no-audio -no-window &
EMULATOR_PID=$!
cd .. || exit 1
export PATH=`pwd`/tools:`pwd`/platform-tools:`pwd`/tools/bin:$PATH || exit 1
cd cn1-unit-tests-android || exit 1
wget https://github.com/codenameone/cn1-binaries/archive/master.zip || exit 1
unzip -q master.zip -d ../ || exit 1
mv ../cn1-binaries-master ../cn1-binaries || exit 1
rm master.zip || exit 1
wget https://github.com/codenameone/codenameone-skins/archive/master.zip || exit 1
unzip -q master.zip -d ../ || exit 1
mv ../codenameone-skins-master ../codenameone-skins || exit 1
cd ../codenameone-skins || exit 1
./build_skins.sh || exit 1
wget https://github.com/codenameone/CodenameOne/archive/master.zip || exit 1
unzip -q master.zip -d ../ || exit 1
mv ../CodenameOne-master ../cn1 || exit 1
cd ../cn1 || exit 1
cd CodenameOne || exit 1
ant jar || exit 1
cd ../CodenameOneDesigner || exit 1
mkdir dist || exit 1
mkdir dist/lib || exit 1
ant release || exit 1
mkdir ../../codenameone-cli || exit 1
cd ../../codenameone-cli || exit 1
npm install codenameone-cli || exit 1
echo "wget https://github.com/shannah/cn1-unit-tests/archive/master.zip"
wget https://github.com/shannah/cn1-unit-tests/archive/master.zip || exit 1
echo "unzip -q master.zip -d ../"
unzip -q master.zip -d ../ || exit 1
mv ../cn1-unit-tests-master ../cn1-unit-tests || exit 1
rm master.zip || exit 1
cd ../cn1-unit-tests || exit 1
echo "bash ../cn1-unit-tests-android/.travis/android-waiting-for-emulator.sh"
bash ../cn1-unit-tests-android/.travis/android-waiting-for-emulator.sh || exit 1
adb shell settings put global window_animation_scale 0 &
adb shell settings put global transition_animation_scale 0 &
adb shell settings put global animator_duration_scale 0 &
sleep 30
echo "adb shell input keyevent 82 &"
adb shell input keyevent 82 &
echo "../codenameone-cli/node_modules/.bin/cn1 test -cn1Sources ../cn1 -s -e -t android -skipCompileCn1Sources -v -p 60"
../codenameone-cli/node_modules/.bin/cn1 test -cn1Sources ../cn1 -s -e -t android -skipCompileCn1Sources -v -p 60 || exit 1
exit 0

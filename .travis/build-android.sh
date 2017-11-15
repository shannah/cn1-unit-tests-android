function doBuild() {
  wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip || return 1
  unzip -q platform-tools-latest-linux.zip -d ../ || return 1
  wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip || return 1
  unzip -q sdk-tools-linux-3859397.zip -d ../ || return 1
  echo yes | ../tools/bin/sdkmanager "tools" || return 1
  #echo yes | ../tools/bin/sdkmanager "platforms;android-25"
  echo yes | ../tools/bin/sdkmanager "${ANDROID_PLATFORM}" || return 1
  #echo yes | ../tools/bin/sdkmanager "system-images;android-25;google_apis;armeabi-v7a"
  echo yes | ../tools/bin/sdkmanager "${ANDROID_SYSTEM_IMAGE}" || return 1
  echo yes | ../tools/bin/sdkmanager "emulator" || return 1
  #echo no | ../tools/bin/avdmanager create avd -k "system-images;android-25;google_apis;armeabi-v7a" -n test -f --tag google_apis --abi armeabi-v7a
  echo no | ../tools/bin/avdmanager create avd -k "${ANDROID_SYSTEM_IMAGE}" -n test -f --tag ${TAG} --abi ${ABI} || return 1
  ../tools/emulator -avd test -no-audio -no-window &
  EMULATOR_PID=$!
  cd .. || return 1
  export PATH=`pwd`/tools:`pwd`/platform-tools:`pwd`/tools/bin:$PATH || return 1
  cd cn1-unit-tests-android || return 1
  wget https://github.com/codenameone/cn1-binaries/archive/master.zip || return 1
  unzip -q master.zip -d ../ || return 1
  mv ../cn1-binaries-master ../cn1-binaries || return 1
  rm master.zip || return 1
  wget https://github.com/codenameone/codenameone-skins/archive/master.zip || return 1
  unzip -q master.zip -d ../ || return 1
  mv ../codenameone-skins-master ../codenameone-skins || return 1
  cd ../codenameone-skins || return 1
  ./build_skins.sh || return 1
  wget https://github.com/codenameone/CodenameOne/archive/master.zip || return 1
  unzip -q master.zip -d ../ || return 1
  mv ../CodenameOne-master ../cn1 || return 1
  cd ../cn1 || return 1
  cd CodenameOne || return 1
  ant jar || return 1
  cd ../CodenameOneDesigner || return 1
  mkdir dist || return 1
  mkdir dist/lib || return 1
  ant release || return 1
  mkdir ../../codenameone-cli || return 1
  cd ../../codenameone-cli || return 1
  npm install codenameone-cli || return 1
  echo "wget https://github.com/shannah/cn1-unit-tests/archive/master.zip"
  wget https://github.com/shannah/cn1-unit-tests/archive/master.zip || return 1
  echo "unzip -q master.zip -d ../"
  unzip -q master.zip -d ../ || return 1
  mv ../cn1-unit-tests-master ../cn1-unit-tests || return 1
  rm master.zip || return 1
  cd ../cn1-unit-tests || return 1
  echo "bash ../cn1-unit-tests-android/.travis/android-waiting-for-emulator.sh"
  bash ../cn1-unit-tests-android/.travis/android-waiting-for-emulator.sh || return 1
  adb shell settings put global window_animation_scale 0 &
  adb shell settings put global transition_animation_scale 0 &
  adb shell settings put global animator_duration_scale 0 &
  sleep 30
  echo "adb shell input keyevent 82 &"
  adb shell input keyevent 82 &
  echo "../codenameone-cli/node_modules/.bin/cn1 test -cn1Sources ../cn1 -s -e -t android -skipCompileCn1Sources -v -p 60"
  ../codenameone-cli/node_modules/.bin/cn1 test -cn1Sources ../cn1 -s -e -t android -skipCompileCn1Sources -v -p 60 || return 1
  return 0
}

RETVAL = $(doBuild)
kill $EMULATOR_PID
exit $RETVAL

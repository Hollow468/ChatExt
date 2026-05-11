.PHONY: get build build_runner test build_android build_ios clean

get:
	flutter pub get

build_runner:
	dart run build_runner build --delete-conflicting-outputs

build: get build_runner
	flutter build

test:
	flutter test

test_unit:
	flutter test test/unit/

test_widget:
	flutter test test/widget/

build_android:
	cd native && bash build_android.sh

build_ios:
	cd native && bash build_ios.sh

proto:
	protoc --dart_out=lib/generated proto/*.proto

clean:
	flutter clean
	dart run build_runner clean

.PHONY: dependencies
dependencies:
	flutter clean && flutter packages get

.PHONY: analyze
analyze:
	flutter analyze

.PHONY: format 
format:
	dart format -l 120 lib/

.PHONY: build-runner
build-runner:
	flutter  pub pub run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch:
	flutter  pub pub run build_runner watch --delete-conflicting-outputs

.PHONY: unit-test
unit-test:
	flutter test --coverage --coverage-path=./coverage/lcov.info

.PHONY: invalidate-cache
invalidate-cache:
	android/gradlew cleanBuildCache

.PHONY: coverage
coverage:
	 flutter test --coverage && lcov --remove coverage/lcov.info 'lib/**.g.dart' 'lib/**.gr.dart' 'lib/**.freezed.dart'   -o coverage/new_lcov.info &&  genhtml coverage/new_lcov.info --output=coverage
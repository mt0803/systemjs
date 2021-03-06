VERSION = $(shell cat package.json | sed -n 's/.*"version": "\([^"]*\)",/\1/p')

define BANNER
/*
 * SystemJS v$(VERSION)
 */
endef
export BANNER

define POLYFILLS_BANNER
/*
 * SystemJS Promise Polyfill
 */
endef
export POLYFILLS_BANNER

define STANDARD_VERSION

System.version = '$(VERSION) Standard';
endef
export STANDARD_VERSION

define REGISTER_VERSION

System.version = '$(VERSION) Register Only';
endef
export REGISTER_VERSION

define CSP_VERSION

System.version = '$(VERSION) CSP';
endef
export CSP_VERSION

compile: clean-compile dist/system.src.js dist/system.perf.js dist/system-csp-production.src.js dist/system-register-only.src.js
build: clean dist/system.js dist/system-csp-production.js dist/system-register-only.js dist/system-polyfills.js

version:
	@echo $(VERSION)

footprint: build
	@cat dist/system.js | gzip -9f | wc -c
	@cat dist/system-csp-production.js | gzip -9f | wc -c
	@cat dist/system-register-only.js | gzip -9f | wc -c
	@cat dist/system-polyfills.js | gzip -9f | wc -c

clean-compile:
	@rm -f dist/system.src.js dist/system.perf.js dist/system-csp-production.src.js

clean:
	@rm -f dist/*

test: compile
	open test/test-traceur.html test/test-traceur-runtime.html
	sleep 0.1
	open test/test-babel.html test/test-babel-runtime.html
	sleep 0.1
	open test/test-typescript.html
	sleep 0.1
	open test/test-csp.html test/test-tracer.html

dist/system-polyfills.js: dist/system-polyfills.src.js
	cd dist && ../node_modules/.bin/uglifyjs $(subst dist/,,$<) --compress drop_console --preamble "$$POLYFILLS_BANNER" --mangle --source-map system-polyfills.js.map >> $(subst dist/,,$@) || rm $(subst dist/,,$@)

dist/%.js: dist/%.src.js
	cd dist && ../node_modules/.bin/uglifyjs $(subst dist/,,$<) --compress drop_console --preamble "$$BANNER" --mangle --source-map $*.js.map >> $(subst dist/,,$@) || rm $(subst dist/,,$@)

dist/system.src.js: lib/*.js
	( echo "$$BANNER"; \
		cat \
			lib/wrapper-start.js \
			lib/url-polyfill.js \
			lib/loader-wrapper-start.js \
				lib/system-fetch.js \
				lib/legacy-transpiler.js \
				lib/proto.js \
				lib/global-eval.js \
				lib/core.js \
				lib/package.js \
				lib/scriptLoader.js \
				lib/register.js \
				lib/esm.js \
				lib/global.js \
				lib/global-helpers.js \
				lib/cjs.js \
				lib/cjs-helpers.js \
				lib/amd-helpers.js \
				lib/amd.js \
				lib/plugins.js \
				lib/conditionals.js \
				lib/alias.js \
				lib/meta.js \
				lib/bundles.js \
				lib/depCache.js \
				lib/createSystem.js \
				; echo "$$STANDARD_VERSION" ; cat \
			lib/loader-wrapper-end.js \
			lib/wrapper-end.js \
	) > $@;

dist/system.perf.js: lib/*.js
	( echo "$$BANNER"; \
		cat \
			lib/wrapper-start.js \
			lib/url-polyfill.js \
			lib/loader-wrapper-start.js \
				lib/legacy-transpiler.js \
				lib/proto.js \
				lib/perf.js \
				lib/global-eval.js \
				lib/core.js \
				lib/package.js \
				lib/scriptLoader.js \
				lib/register.js \
				lib/esm.js \
				lib/global.js \
				lib/global-helpers.js \
				lib/cjs.js \
				lib/cjs-helpers.js \
				lib/amd-helpers.js \
				lib/amd.js \
				lib/plugins.js \
				lib/conditionals.js \
				lib/alias.js \
				lib/meta.js \
				lib/bundles.js \
				lib/depCache.js \
				lib/createSystem.js \
				; echo "$$STANDARD_VERSION" ; cat \
			lib/loader-wrapper-end.js \
			lib/wrapper-end.js \
	) > $@;

dist/system-csp-production.src.js: lib/*.js
	( echo "$$BANNER"; \
		cat \
			lib/wrapper-start.js \
			lib/url-polyfill.js \
			lib/loader-wrapper-start.js \
				lib/proto.js \
				lib/system-fetch.js \
				lib/core.js \
				lib/package.js \
				lib/scriptLoader.js \
				lib/register.js \
				lib/global-helpers.js \
				lib/cjs-helpers.js \
				lib/amd-helpers.js \
				lib/plugins.js \
				lib/conditionals.js \
				lib/alias.js \
				lib/meta.js \
				lib/bundles.js \
				lib/depCache.js \
				lib/scriptOnly.js \
				lib/createSystem.js \
				; echo "$$CSP_VERSION" ; cat \
			lib/loader-wrapper-end.js \
			lib/wrapper-end.js \
	) > $@;

dist/system-register-only.src.js: lib/*.js
	( echo "$$BANNER"; \
		cat \
			lib/url-polyfill.js \
			lib/loader-wrapper-start.js \
				lib/proto.js \
				lib/system-only-resolve.js \
				lib/scriptLoader.js \
				lib/register.js \
				lib/bundles.js \
				lib/scriptOnly.js \
				lib/createSystem.js \
				; echo "$$REGISTER_VERSION" ; cat \
			lib/loader-wrapper-end.js \
	) > $@;

dist/system-polyfills.src.js: lib/*.js
	( echo "$$POLYFILLS_BANNER"; \
		echo "(function(define) {"; \
		echo ""; \
		cat \
			node_modules/when/es6-shim/Promise.js \
			lib/polyfills-bootstrap.js; \
		echo "})();" \
	) > $@;
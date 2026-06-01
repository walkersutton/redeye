.PHONY: kill preview publish publish-patch publish-minor publish-major release-patch release-minor release-major

kill:
	scripts/kill.sh

preview:
	scripts/preview.sh

publish:
	scripts/publish.sh patch

publish-patch:
	scripts/publish.sh patch

publish-minor:
	scripts/publish.sh minor

publish-major:
	scripts/publish.sh major

release-patch:
	scripts/release.sh patch

release-minor:
	scripts/release.sh minor

release-major:
	scripts/release.sh major

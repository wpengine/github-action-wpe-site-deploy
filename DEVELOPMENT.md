# Development

## Creating a release

1. In GitHub, visit "Releases -> Draft new release"
2. In the "Choose a tag" dropdown, enter a tag name for the release. The tag name should follow the format `v{MAJOR}.{MINOR}.{PATCH}`, where the version number is prefixed with the letter `v` and all three SemVer levels are specified.
3. Leave the target branch set to `main`.
4. Give the release a title. Typically, this will be identical to the release's tag name.
5. Use the "Generate release notes" button to populate the release body. If you'd like to add any additional information or make edits to the auto-generated text, feel free to do so.
6. Once you're happy with the release notes, click "Publish Release".

You're done! Publishing the release will create the patch tag (i.e. `v3.0.1`) and trigger an action to update the major (`v3`) and minor (`v3.0`) tags.

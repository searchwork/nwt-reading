# Contribution Guidelines

Thank you for your interest in contributing to NWT Reading! We appreciate your help in making this project better.

This document outlines the guidelines for contributing to this project. Please take a moment to review them before submitting your contributions.

## Code of Conduct

Please review and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to uphold the principles outlined in that document.

## Reporting Bugs

1. **Search Existing Issues:** Before creating a new issue, please search the existing issues to see if the bug has already been reported.
2. **Create a New Issue:** If the bug hasn't been reported, create a new issue using the "Bug report" template.
3. **Provide Detailed Information:** In your bug report, please include the following information:
    - A clear and concise description of the bug.
    - Steps to reproduce the bug.
    - The expected behavior.
    - The actual behavior.
    - Your operating system and version.
    - The version of NWT Reading you are using.
    - Any relevant error messages or screenshots.
    - The device or platform you are using (Android, iOS, Linux, macOS, Web, Windows).

## Suggesting Enhancements

1. **Search Existing Issues:** Before creating a new issue, please search the existing issues to see if the enhancement has already been suggested.
2. **Create a New Issue:** If the enhancement hasn't been suggested, create a new issue using the "Feature request" template.
3. **Provide Detailed Information:** In your enhancement request, please include the following information:
    - A clear and concise description of the enhancement.
    - The motivation for the enhancement.
    - Any potential solutions or alternatives.

## Commit Message Guidelines

- Use clear and concise commit messages.
- Use the following format:

    ```text
    <scope>: <subject>

    <body>

    <footer>
    ```

  - **scope:** The scope of the change (e.g., `plans`, `schedules`, `assets/repositories`, `integration_test`).
  - **subject:** A short description of the change. Use the present tense ("add feature" not "added feature"). Use the imperative mood ("move asset to..." not "moves asset to...").
  - **body:** (Optional) A longer description of the change.
  - **footer:** (Optional) Any relevant information, such as issue numbers or breaking changes.

    Example: `assets/repositories: update bible_languages`

## Pull Requests

1. **Single Bug or Feature per Pull Request:** Each pull request should address a single bug fix or implement a single feature. This makes it easier to review and merge changes.
2. **Fork the Repository:** Fork the repository to your own GitHub account.
3. **Create a Branch:** Create a new branch for your changes. Use a descriptive branch name, such as `new-reading-mode` or `fix-plan-edit`.
4. **Make Your Changes:** Make your changes and commit them to your branch.
5. **Platform Compatibility:** Ensure your code changes work across all supported platforms (Android, iOS, Linux, macOS, Web, and Windows). Platform-specific code should generally be limited to the platform directory (e.g., `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`). Avoid adding platform-specific code to common code unless absolutely necessary.
6. **Follow Coding Standards:** Write clean code. Ensure your code adheres to the project's Flutter coding standards.
7. **Write Tests:** If you are adding new features or fixing bugs, please write Flutter widget and unit tests to ensure your changes are correct.
8. **Update Documentation:** If you are adding new features or changing existing features, please update the documentation accordingly, including inline code comments.
9. **Test Your Code:** Run `./scripts/test.sh` to test your code locally. This script does code linting and runs Flutter unit, and integration tests. Ensure all tests pass.
10. **Create a Pull Request:** Create a pull request from your branch to the `main` branch of the original repository.
11. **Describe Your Changes:** In your pull request, please provide a clear and concise description of your changes.
12. **License Declaration:** In your pull request description, please add the following statement: "I confirm that my contributions are licensed under the AGPL-3.0 License and do not infringe on any third-party intellectual property rights."
13. **Address Review Comments:** Be prepared to address any review comments and make changes as needed.

## License and Contributor Agreement

By contributing to this project, you agree that your contributions will be licensed under the AGPL-3.0 License. Further, by submitting a pull request, you declare that your contributions are your own original work or that you have the necessary rights and permissions to contribute them under the AGPL-3.0 License, and that your contributions do not infringe on any third-party intellectual property rights.

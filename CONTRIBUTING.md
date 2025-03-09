# Contribution Guidelines

Thank you for your interest in contributing to NWT Reading! We appreciate your help in making this project better.

This document outlines the guidelines for contributing to this project. Please take a moment to review them before submitting your contributions.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [License and Contributor Agreement](#license-and-contributor-agreement)

## Code of Conduct

Please review and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to uphold the principles outlined in that document.

## How to Contribute

### Reporting Bugs

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

### Suggesting Enhancements

1. **Search Existing Issues:** Before creating a new issue, please search the existing issues to see if the enhancement has already been suggested.
2. **Create a New Issue:** If the enhancement hasn't been suggested, create a new issue using the "Feature request" template.
3. **Provide Detailed Information:** In your enhancement request, please include the following information:
    - A clear and concise description of the enhancement.
    - The motivation for the enhancement.
    - Any potential solutions or alternatives.

### Pull Requests

1. **Fork the Repository:** Fork the repository to your own GitHub account.
2. **Create a Branch:** Create a new branch for your changes. Use a descriptive branch name, such as `new-reading-mode` or `fix-plan-edit`.
3. **Make Your Changes:** Make your changes and commit them to your branch.
4. **Platform Compatibility:** Ensure your code changes work across all supported platforms (Android, iOS, Linux, macOS, Web, and Windows). Platform-specific code should generally be limited to the platform directory (e.g., `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`). Avoid adding platform-specific code to common code unless absolutely necessary.
5. **Follow Coding Standards:** Ensure your code adheres to the project's Flutter coding standards.
6. **Write Tests:** If you are adding new features or fixing bugs, please write Flutter widget and unit tests to ensure your changes are correct.
7. **Update Documentation:** If you are adding new features or changing existing features, please update the documentation accordingly, including inline code comments.
8. **Create a Pull Request:** Create a pull request from your branch to the `main` branch of the original repository.
9. **Describe Your Changes:** In your pull request, please provide a clear and concise description of your changes.
10. **License Declaration:** In your pull request description, please add the following statement: "I confirm that my contributions are licensed under the AGPL-3.0 License."
11. **Address Review Comments:** Be prepared to address any review comments and make changes as needed.

## Development Setup

1. **Clone the Repository:** Clone your forked repository to your local machine.

    ```bash
    git clone https://github.com/searchwork/nwt-reading.git
    ```

2. **Install Flutter:** Ensure you have Flutter installed and configured on your system. Refer to the official Flutter documentation for installation instructions: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
3. **Install Dependencies:** Navigate to the project directory and run the following command to install the project's dependencies:

    ```bash
    flutter pub get
    ```

4. **Run Tests:** Run the project's tests to ensure everything is working correctly:

    ```bash
    flutter test
    ```

5. **Run the App:** Run the app on an emulator or physical device/platform:

    ```bash
    flutter run
    ```

## Coding Standards

- Follow the official Flutter style guide: [https://flutter.dev/docs/style-guide](https://flutter.dev/docs/style-guide)
- Use `flutter format` to format your code.
- Write clear, readable, and well-documented code.
- Use meaningful variable and function names.
- Add comprehensive comments, especially for complex logic.
- Use effective state management.
- Keep UI code clean and maintainable.
- Write widget and unit tests.

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

## License and Contributor Agreement

By contributing to this project, you agree that your contributions will be licensed under the AGPL-3.0 License. Further, by submitting a pull request, you declare that your contributions are your own original work or that you have the necessary rights and permissions to contribute them under the AGPL-3.0 License.

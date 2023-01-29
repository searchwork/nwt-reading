# Architecture

## Layers

The architecture is based on the [Clean Architecture] pattern using the following layers:

[Clean Architecture]: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

[![Architecture](architecture.drawio.svg)](architecture.drawio.svg)

### Entities

The entities contain the application independent **business rules**.

The data **types** are exposed as [immutable classes] and the **objects** as [Riverpod] [AsyncNotifierProvider] objects called `<model>Provider` respectively `<model>FamilyProvider`.

[immutable classes]: https://dart.academy/immutable-data-patterns-in-dart-and-flutter
[Riverpod]: https://docs-v2.riverpod.dev
[AsyncNotifierProvider]: https://pub.dev/documentation/riverpod/latest/riverpod/AsyncNotifier-class.html

### Stories

The stories contain the user stories, that is **application specific business rules** (specific to the automation).

### Presentations

The presentation layer contains the **user interface** related objects.

### Repositories

Repositories assure **data access and persistence**. They are [initialized] by the main function using the [Riverpod] [ProviderContainer] class.

[initialized]: https://codewithandrea.com/articles/riverpod-initialize-listener-app-startup/
[ProviderContainer]: https://pub.dev/documentation/riverpod/latest/riverpod/ProviderContainer-class.html

## Dependency Rules

- Across architectural boundaries all dependencies point **inwards**, that is towards the entities (the business rules).
- Inner rings must **not depend on outer rings**.
- **Sections on the same ring** should not depend on each other. They may use each other indirectly through inner rings.

## Dependency Inversion

Logically the **entities** or **stories** depend on **repositories** to be **initialized** or **updated** with data from persistent stores like assets, Shared Preferences or network services.

These inner layers however should **not depend on** or **know about** the outer layer classes. This is achieved by using a **modified AsyncNotifier** class called [IncompleteNotifier]. The **IncompleteNotifier** does not build until it is initialized by the repository.

[IncompleteNotifier]: ../lib/src/base/entities/incomplete_notifier.dart

### Shared Preferences Repository Provider

When **initialized** Shared Preferences repository providers **read the shared preference** and **initialize** the entity respectively story **provider**.

They **listen** to the provider and **store state changes** to shared preferences.

### Asset Repository Providers

On **initialization** they read the asset(s) and **initialize** the entity respectively story **provider**.

## Code Structure

The code in [`lib/src`] is **grouped by domains** respectively high level features and **then by the architectural layers** (domain driven approach).

[`lib/src`]: ../lib/src

## Unit Testing

The **AsyncNotifiers** are tested using [ProviderContainers and Listeners].

[ProviderContainers and Listeners]: https://docs-v2.riverpod.dev/docs/cookbooks/testing

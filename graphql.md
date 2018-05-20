# GraphQL API

The service exposes a public GraphQL interface. The full documentation can be found at [/api](/api).

## Error Handling

Queries that may result in an error (user input, or internal error) are exposed using a union. Where the error types are objects that implement the `GenericError` interface. While any other types are those defined by that specific query.

### Debugging

To aid in debugging (especially when unsure if the error is meant to be expected) a `@debug` directive can be added to any field. This directive will enable any debug related functionality, such as returning server errors/crashes.

```graphql
query {
  someBrokenField @debug {
    ... on InternalError {
      exception
      stacktrace
    }
  }
}
```

#### InternalError

The internal error type is a special type that exposes server errors to aid in debugging. This type won't be available in proper distributions.


## Headers

Below are the list of header attributes that can be set to specify global parameters to apply to the queries.

### X-API-Key

Store the API key for the consumer of the API. **Note: Currently this is ignored.**

### Authorization

Store the bearer access token for a given identity. Should take the form of `Bearer <token>`.

### Accept-Language

Indicate the current locale(s) to be used. e.g. `en-AU`.


## Authentication

### Registration

To create an identity, the `register` mutation can be called. Passing in the initial authentication credential to associate with this identity.

```graphql
mutation {
  register (emailCredential: { email: "foo@bar", password: "test" }) @debug {
    ... on Session {
      accessToken
      refreshToken
    }
  }
}
```

### Login

To login into an identity, the `login` mutation can be called. Passing in an authentication credential that is associated with the target identity.

```graphql
mutation {
  login (emailCredential: { email: "foo@bar", password: "test" }) @debug {
    ... on Session {
      accessToken
      refreshToken
    }
  }
}
```

### Refresh

A session can be refreshed using the `refresh` mutation. Passing in the session to be refreshed.

```graphql
mutation {
  refresh (session: {
      accessToken: "accessToken",
      refreshToken: "refreshToken"
  }) {
    ... on Session {
      accessToken
      refreshToken
    }
  }
}
```

### Logout

To logout from an active session, the `logout` mutation can be called. Passing in the session to be invalidated.

```graphql
mutation {
  logout (session: {
      accessToken: "accessToken",
      refreshToken: "refreshToken"
  }) {
    ... on Session {
      accessToken
      refreshToken
    }
  }
}
```


## Identity

All data associated with an identity is referenced through fields belonging to the `Identity` type. To obtain this type either pass in the access token as a argument for the identity field, or store it in the header.

```graphql
query {
  identity (accessToken: "accessToken") {
    ... on Identity {
      id
      token
      contacts {
        ... on Contact {
          status
          priority
          presentable
        }
      }
      credentials {
        ... on Credential {
          type
          status
          presentable
        }
      }
    }
  }
}

query {
  identity { # References access token in header (Authorization: Bearer accessToken)
    ... on Identity {
      id
      token
      contacts {
        ... on Contact {
          status
          priority
          presentable
        }
      }
      credentials {
        ... on Credential {
          type
          status
          presentable
        }
      }
    }
  }
}
```

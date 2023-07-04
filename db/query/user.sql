-- name: CreateUser :one

INSERT INTO
    users (
        hashed_password,
        username,
        avatar,
        email,
        balance,
        address,
        file_path,
        secret_code,
        isBiomatric,
        is_used,
        is_email_verified
    )
VALUES (
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10,
        $11
    ) RETURNING *;

-- name: GetUser :one

SELECT * FROM users WHERE username = $1 OR email = $1 LIMIT 1;

-- name: ChangePassword :one

UPDATE users
SET
    hashed_password = $2,
    password_changed_at = $3
WHERE username = $1 RETURNING *;

-- name: CheckUsernameExists :one

SELECT EXISTS (
        SELECT 1
        FROM users
        WHERE username = $1
        LIMIT 1
    );

-- name: DeleteUser :one

DELETE FROM users WHERE username = $1 RETURNING *;

-- name: UpdateUser :one

UPDATE users
SET
    hashed_password = COALESCE(
        sqlc.narg(hashed_password),
        hashed_password
    ),
    password_changed_at = COALESCE(
        sqlc.narg(password_changed_at),
        password_changed_at
    ),
    email = COALESCE(sqlc.narg(email), email),
    is_email_verified = COALESCE(
        sqlc.narg(is_email_verified),
        is_email_verified
    ),
    avatar = COALESCE(sqlc.narg(avatar), avatar),
    balance = COALESCE(sqlc.narg(balance), balance),
    secret_code = COALESCE(
        sqlc.narg(secret_code),
        secret_code
    ),
    -- isBiomatric = COALESCE(
    --     sqlc.narg(isBiomatric),
    --     isBiomatric
    -- ),
    expired_at = COALESCE(
        sqlc.narg(expired_at),
        expired_at
    ),
    is_used = COALESCE(sqlc.narg(is_used), is_used)
WHERE
    username = sqlc.arg(username) RETURNING *;
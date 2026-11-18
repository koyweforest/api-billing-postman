# Contributing

## Example values in the collection and API spec

Examples in the documentation, the OpenAPI spec (`openapi.json`) and the Postman
collection (`facto.postman_collection.json`) must use only fictitious values. Never
copy values from production or sandbox requests, responses or screenshots.

| Kind | Use |
| --- | --- |
| Prefixed UUID ids | `acc_00000000-0000-0000-0000-000000000000` (keep the prefix; use `...000000000001`, `...000000000002` when an example needs several) |
| Plain UUIDs | `00000000-0000-0000-0000-000000000000` |
| ObjectIds | `000000000000000000000000` |
| Credentials | `YOUR_API_KEY`, `YOUR_CLIENT_SECRET`, `YOUR_PASSWORD` or a Postman variable such as `{{session_token}}` |
| Emails | `user@example.com` |
| Tax ids | Obviously fake values such as `11111111-1` / `76000000-0` (CL-RUT) |
| Names, phones, addresses | Generic values such as `Example Company S.A.`, `+56900000000`, `Calle Ejemplo 123` |

Screenshots in `assets/` must not show tokens, secrets or real customer data.

`scripts/check-example-ids.sh` runs on every pull request and fails when it finds
a UUID or ObjectId that is not a placeholder, or a credential-like value. Run it
locally with:

```bash
bash scripts/check-example-ids.sh
```

If a value is known not to identify anything real, add it (exact match, one per
line) to `.example-ids-allowlist`.

---

## Valores de ejemplo en la colección y la especificación (ES)

Los ejemplos de la documentación, la especificación OpenAPI y la colección de
Postman deben usar solo valores ficticios: UUID en cero con el prefijo
correspondiente (`acc_00000000-0000-0000-0000-000000000000`),
`000000000000000000000000` para ObjectIds, correos `@example.com`, y `YOUR_API_KEY`
/ `YOUR_CLIENT_SECRET` / `YOUR_PASSWORD` o variables de Postman para credenciales.
Nunca copies valores de producción ni de sandbox (tampoco en capturas de pantalla).
El script `scripts/check-example-ids.sh` se ejecuta en cada pull request y falla si
encuentra un identificador o credencial que no sea un valor de ejemplo.

# My Solo Cycle Rides

Digital photobooks from solo bicycle adventures — live at https://cycling.sankarson.in

## Layout

| Folder    | Contents                                              |
| --------- | ----------------------------------------------------- |
| `web/`    | Static website (deployed from this folder)            |
| `ios/`    | iOS app (Xcode project)                               |
| `tvos/`   | tvOS app (Xcode project)                              |
| `shared/` | Optional Swift package shared by the iOS/tvOS apps   |

## Deploying the website

Cloudflare (Workers static assets, see `wrangler.jsonc`): `.github/workflows/cloudflare.yml` deploys `web/` on every push to `main`.

Photos are not bundled in the apps; they load from the website's WebP pages.

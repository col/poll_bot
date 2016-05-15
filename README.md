# PollBot

## Bot Usage

    /new_poll What's for dinner?
    /option Mexican
    /option Pizza, Sushi
    /done

        What's for dinner?
        - Mexican
        - Pizza
        - Sushi

    /vote Mexican

        You voted for Mexican

    /poll

        What's for dinner?
        Mexican: 1
        Pizza: 0
        Sushi: 0

## Start Local

    iex --name "poll_bot@127.0.0.1" -S mix

## Deployment

    mix edeliver build release
    mix edeliver deploy release to production --version=0.0.x
    mix edeliver start production

## Upgrade

  mix edeliver build upgrade --from=0.0.x --to=0.0.z
  mix edeliver deploy upgrade to production --version=0.0.z    

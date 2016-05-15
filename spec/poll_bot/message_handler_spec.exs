defmodule PollBot.MessageHandlerSpec do
  use ESpec

  describe "create new poll" do
    let :message, do: %Telegram.Message{ command: "/newpoll", params: ["What's", "for", "dinner?"]}

    context "when no poll exists" do
      let :state, do: %{}

      it "should set the poll title" do
        {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
        expect new_state.title |> to(eq "What's for dinner?")
      end

      it "should set the options to an empty map" do
        {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
        expect new_state.options |> to(eq %{})
      end
    end

    context "when a poll already exists" do
      let :state, do: %{title: "What movie?", options: %{"X-Men" => [], "Deadpool" => [], "Bond" => []}}

      it "should set the title for the new poll" do
        {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
        expect new_state.title |> to(eq "What's for dinner?")
      end

      it "should clear the options" do
        {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
        expect new_state.options |> to(eq %{})
      end
    end
  end

  describe "add option" do
    let :message, do: %Telegram.Message{ command: "/options", params: ["Mexican"]}

    context "when the option doesn't exist" do
      let :state, do: %{title: "What's for dinner?", options: %{}}

      it "should add the option" do
        {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
        expect new_state.options |> to(eq %{"Mexican" => []})
      end
    end

    context "when the option already exists" do
      let :state, do: %{title: "What's for dinner?", options: %{"Mexican" => [1]}}

      it "should NOT reset the vote count" do
        {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
        expect new_state.options |> to(eq %{"Mexican" => [1]})
      end
    end
  end

  describe "add multiple options (separated by commas)" do
    let :message, do: %Telegram.Message{ command: "/options", params: ["Mexican,", "Fish", "and", "Chips"]}
    let :state, do: %{title: "What's for dinner?", options: %{"Pizza" => [1]}}

    it "should add all the options" do
      {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
      expect new_state.options |> to(eq %{"Pizza" => [1], "Mexican" => [], "Fish and Chips" => []})
    end
  end

  describe "publish the poll" do
    let :message, do: %Telegram.Message{command: "/done"}
    let :state, do: %{title: "What's for dinner?", options: %{"Mexican" => [], "Pizza" => [], "Sushi" => []}}

    it "should not change the poll" do
      {new_state, _} = PollBot.MessageHandler.handle_message(message, state)
      expect new_state |> to(eq state)
    end

    it "should respond with the poll info" do
      {_, response} = PollBot.MessageHandler.handle_message(message, state)
      expect response |> to(eq "What's for dinner?\n- Mexican\n- Pizza\n- Sushi")
    end
  end

  describe "vote" do
    let :message, do: %Telegram.Message{command: "/vote", params: ["Mexican"], from: %Telegram.User{id: 1, first_name: "Col"}}

    context "user votes for option with no votes" do
      let :poll, do: %{title: "What's for dinner?", options: %{"Mexican" => [], "Pizza" => [], "Sushi" => []}}
      it "should add users vote" do
        {poll, _} = PollBot.MessageHandler.handle_message(message, poll)
        expect poll.options |> to(eq %{"Mexican" => [1], "Pizza" => [], "Sushi" => []})
      end
      it "should respond by repeating the users response" do
        {_, response} = PollBot.MessageHandler.handle_message(message, poll)
        expect response |> to(eq "Col voted for Mexican")
      end
    end

    context "user votes for option with existing vote" do
      let :poll, do: %{title: "What's for dinner?", options: %{"Mexican" => [2], "Pizza" => [], "Sushi" => []}}
      it "should add users vote to the existing vote" do
        {poll, _} = PollBot.MessageHandler.handle_message(message, poll)
        expect poll.options |> to(eq %{"Mexican" => [1, 2], "Pizza" => [], "Sushi" => []})
      end
    end

    context "user votes for option twice" do
      let :poll, do: %{title: "What's for dinner?", options: %{"Mexican" => [1, 2], "Pizza" => [], "Sushi" => []}}
      it "should only record the users vote once" do
        {poll, _} = PollBot.MessageHandler.handle_message(message, poll)
        expect poll.options |> to(eq %{"Mexican" => [1, 2], "Pizza" => [], "Sushi" => []})
      end
    end

    context "user changes vote to different option" do
      let :poll, do: %{title: "What's for dinner?", options: %{"Mexican" => [], "Pizza" => [1], "Sushi" => []}}
      it "should add the users vote to correct option and remove the previous vote" do
        {poll, _} = PollBot.MessageHandler.handle_message(message, poll)
        expect poll.options |> to(eq %{"Mexican" => [1], "Pizza" => [], "Sushi" => []})
      end
    end

    context "user votes for a poll that doesn't exist" do
      let :poll, do: %{title: "What's for dinner?", options: %{"Pizza" => [], "Sushi" => []}}
      it "should respond with an error message" do
        {_, response} = PollBot.MessageHandler.handle_message(message, poll)
        expect response |> to(eq "Mexican is not a valid option")
      end
    end
  end

  describe "view" do
    let :poll, do: %{title: "What's for dinner?", options: %{"Mexican" => [1, 2, 3], "Pizza" => [4], "Sushi" => [5, 6]}}
    let :message, do: %Telegram.Message{command: "/poll"}

    it "should respond with the poll info" do
      {_, response} = PollBot.MessageHandler.handle_message(message, poll)
      expect response |> to(eq "What's for dinner?\n- Mexican: 3 votes\n- Pizza: 1 vote\n- Sushi: 2 votes")
    end
  end
end

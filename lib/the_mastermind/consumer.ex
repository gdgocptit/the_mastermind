defmodule TheMastermind.Consumer do
  alias TheMastermind.Account.User
  alias TheMastermind.Account
  import Nostrum.Struct.Embed

  @behaviour Nostrum.Consumer

  def handle_event({:READY, _ready, _ws_state}) do
    :logger.info("Bot is ready!")
    guild_id = Application.get_env(:the_mastermind, :guild_id)

    slashs = [
      Nosedrum.Storage.Dispatcher.add_command("announce", TheMastermind.Discord.Slashs.Announce, guild_id)
    ]

    Nostrum.Api.Self.update_status(:online, {:listening, "localhost:4000"})

    slashs
    |> Enum.each(fn slash ->
      case slash do
        {:ok, cmd} -> :logger.info("Registered command: #{cmd.name}")
        {:error, reason} -> :logger.error("Failed to register command: #{inspect(reason)}")
      end
    end)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when interaction.type == 2 do
    Nosedrum.Storage.Dispatcher.handle_interaction(interaction)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when interaction.type == 5 do
    case interaction.data.custom_id do
      "received_announce_modal" ->
        [%Nostrum.Struct.Message.Component{components: [input_component]}] = interaction.data.components
        student_id = String.upcase(input_component.value)
        discord_id = interaction.member.user_id

        record_by_student_id = TheMastermind.Repo.get_by(User, student_id: student_id)
        Account.update_user(record_by_student_id, %{discord_id: discord_id})

        handle_submitted_received_announcement(interaction)

      _ -> :ok
    end
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when interaction.type == 3 do
    case interaction.data.custom_id do
      "received_announce_submit" ->
        if !Account.exists_by_discord_id?(interaction.member.user_id) do
          handle_input_student_id_modal(interaction)
        end

        announcement_record = TheMastermind.Interaction.get_announcement_by_message_id!(interaction.message.id)

        if TheMastermind.Interaction.received_announcement?(announcement_record, interaction.member.user_id) do
          handle_already_received_announcement(interaction)
        else
          TheMastermind.Interaction.submit_received_announcement(announcement_record, interaction.member.user_id)

          handle_submitted_received_announcement(interaction)
        end


      _ -> :ok
    end
  end
  def handle_event(_), do: :ok

  defp handle_already_received_announcement(interaction) do
    embed = %Nostrum.Struct.Embed{}
    |> put_description("Bạn đã xác nhận nhận thông báo này rồi!")
    |> put_color(0x4287F5)

    Nostrum.Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{
        embeds: [embed],
        flags: 64
      }
    })
  end

  def handle_submitted_received_announcement(interaction) do
    embed = %Nostrum.Struct.Embed{}
    |> put_description("Đã xác nhận thông báo!")
    |> put_color(0x4287F5)

    Nostrum.Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{
        embeds: [embed],
        flags: 64
      }
    })
  end

  defp handle_input_student_id_modal(interaction) do
    student_id_input = %{
      type: 4,
      custom_id: "student_id",
      label: "Mã sinh viên (chỉ yêu cầu cho lần đầu):",
      style: 1,
      min_length: 10,
      max_length: 10,
      required: true,
      placeholder: "B12DCCN345"
    }

    action_row = %{type: 1, components: [student_id_input]}
    Nostrum.Api.Interaction.create_response(interaction, %{
      type: 9,
      data: %{
        title: "Yêu cầu mã sinh viên",
        custom_id: "received_announce_modal",
        components: [action_row]
      }
    })
  end
end

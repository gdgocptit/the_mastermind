defmodule TheMastermind.Discord.Slashs.Announce do
  @behaviour Nosedrum.ApplicationCommand

  alias Nostrum.Struct.ApplicationCommandInteractionDataOption

  import Nostrum.Struct.Component.Button, only: [interaction_button: 3]
  import Nostrum.Struct.Component.ActionRow, only: [action_row: 1]
  import Nostrum.Struct.Embed

  @impl true
  def description, do: "Thông báo tin nhắn đến mọi người"

  @impl true
  def type, do: :slash

  @impl true
  def command(interaction) do
    [
      %ApplicationCommandInteractionDataOption{
        name: "channel",
        value: channel_id
      },
      %ApplicationCommandInteractionDataOption{
        name: "message",
        value: message_link
      }
    ] = interaction.data.options

    {:ok, %{channel_id: message_channel_id, message_id: message_id}} = parse_message_link(message_link)

    {:ok, %Nostrum.Struct.Message{content: msg_content, embeds: msg_embeds}} = Nostrum.Api.Message.get(message_channel_id, message_id)

    received_announce_button = interaction_button("Đã nhận thông báo", "received_announce_submit", style: 3)
    action_row = action_row([received_announce_button])

    {:ok, announcement} = Nostrum.Api.Message.create(channel_id, content: msg_content, components: [action_row], embeds: msg_embeds)

    TheMastermind.Repo.insert(%TheMastermind.Interaction.Announcement{message_id: announcement.id})

    response_embed = %Nostrum.Struct.Embed{}
    |> put_description("Đã gửi thông báo thành công!")
    |> put_color(0x32A852)

    [embeds: [response_embed]]
  end

  @impl true
  def options do
    [
      %{
        type: :channel,
        name: "channel",
        description: "Kênh để gửi thông báo",
        required: true
      },
      %{
        type: :string,
        name: "message",
        description: "Link của nội dung message muốn thông báo",
        required: true
      }
    ]
  end

  defp parse_message_link(message_link) do
    regex = ~r/channels\/\d+\/(\d+)\/(\d+)$/

    case Regex.run(regex, message_link) do
      [_, channel_id, message_id] -> {:ok, %{channel_id: String.to_integer(channel_id), message_id: String.to_integer(message_id)}}
      nil -> {:error, nil}
    end
  end
end


defmodule TheMastermind.Discord.Slashs.DelAnnounce do
  import Ecto.Query, only: [from: 2]
  alias Nostrum.Struct.ApplicationCommandInteractionDataOption

  import Nostrum.Struct.Embed

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Xóa một thông báo đã gửi"

  @impl true
  def type, do: :slash

  @impl true
  def command(interaction) do
    [
      %ApplicationCommandInteractionDataOption{
        name: "message_link",
        value: message_link
      }
    ] = interaction.data.options

    {:ok, %{channel_id: message_channel_id, message_id: message_id}} = parse_message_link(message_link)

    exist_query_announcement = from a in TheMastermind.Interaction.Announcement, where: a.message_id == ^message_id
    if TheMastermind.Repo.exists?(exist_query_announcement) do
      TheMastermind.Repo.delete!(TheMastermind.Interaction.get_announcement_by_message_id!(message_id))
      Nostrum.Api.Message.delete(message_channel_id, message_id)

      response_embed = %Nostrum.Struct.Embed{}
      |> put_description("Đã xóa thông báo thành công!")
      |> put_color(0x32A852)

      [embeds: [response_embed]]
    else
      response_embed = %Nostrum.Struct.Embed{}
      |> put_description("Link message được chỉ định không phải là một thông báo\n\n**Hoặc**\n\nĐã bị xóa trước đó!")
      |> put_color(0xEB4034)

      [embeds: [response_embed]]
    end
  end

  @impl true
  def options do
    [
      %{
        type: :string,
        name: "message_link",
        description: "Kênh để gửi thông báo",
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

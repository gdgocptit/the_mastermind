defmodule Mix.Tasks.SetupDiscordRoles do
  use Mix.Task

  alias TheMastermind.Repo
  alias TheMastermind.Account.User

  @shortdoc "Setup Discord roles based on the roles defined in the database"
  def run([csv_file_path]) do
    Mix.Task.run("app.start")

    csv_file_path |> File.exists?() |> case do
      true -> :ok
      false ->
        Mix.shell().error("File #{csv_file_path} does not exist.")
        System.halt(1)
    end

    csv_file_path
    |> File.read!()
    |> NimbleCSV.RFC4180.parse_string()
    |> Enum.reduce(Ecto.Multi.new(), fn [student_id, discord_role_id], multi ->
      Ecto.Multi.update(multi, student_id,
        User.changeset(
          Repo.get_by!(User, student_id: student_id),
          %{discord_role_id: String.to_integer(discord_role_id)}
        )
      )
    end)
    |> Repo.transact()
    |> case do
      {:error, failed_op, failed_value, _changes_so_far} ->
        Mix.shell().error("Failed to update user #{failed_op}: #{inspect(failed_value)}")
        System.halt(1)
      {:ok, _results} -> :ok
    end

    Mix.shell().info("Discord roles setup completed.")
  end
end

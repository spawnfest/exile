defmodule ExileAuth.Guardian do
  use Guardian, otp_app: :exile_auth
  #use Guardian.Permissions

  alias ExileAuth.Accounts

  # Fetches the subject for a token for the provided resource and claims.
  # The subject should be a short identifier that can be used to identify the
  # resource.
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_resource_id}
  end

  # Fetches the resource that is represented by claims.
  # For JWT this would normally be found in the sub field.
  def resource_from_claims(%{"sub" => id}) do
    IO.puts(IO.inspect(id))
    case Accounts.get_user!(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_) do
    {:error, :no_claims_sub}
  end
end

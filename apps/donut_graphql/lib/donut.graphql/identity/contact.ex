defmodule Donut.GraphQL.Identity.Contact do
    use Donut.GraphQL.Schema.Notation

    @desc "The priority of a contact"
    enum :contact_priority do
        value :primary
        value :secondary
    end

    @desc "A generic contact interface"
    interface :contact do
        field :priority, non_null(:contact_priority), description: "The priority of the contact"
        field :status, non_null(:verification_status), description: "The current verification status of the contact"
        field :presentable, non_null(:string), description: "The presentable information about the contact"
    end

    @desc "An email contact"
    object :email_contact do
        field :priority, non_null(:contact_priority), description: "The priority of the email contact"
        field :status, non_null(:verification_status), description: "The current verification status of the email contact"
        field :presentable, non_null(:string), description: "The presentable information about the email contact"
        field :email, non_null(:string), description: "The email address"

        interface :contact

        is_type_of fn
            %{ email: _ } -> true
            _ -> false
        end
    end

    @desc "A mobile contact"
    object :mobile_contact do
        field :priority, non_null(:contact_priority), description: "The priority of the mobile contact"
        field :status, non_null(:verification_status), description: "The current verification status of the mobile contact"
        field :presentable, non_null(:string), description: "The presentable information about the mobile contact"
        field :mobile, non_null(:string), description: "The mobile number"

        interface :contact

        is_type_of fn
            %{ mobile: _ } -> true
            _ -> false
        end
    end

    @desc """
    The collection of possible results from a contact request. If successful
    returns the `Contact` trying to be accessed, otherwise returns an error.
    """
    result :contact, [:email_contact, :mobile_contact]

    object :contact_queries do
        @desc "The contacts associated with the identity"
        field :contacts, list_of(result(:contact)) do
            @desc "The status of the contacts to retrieve"
            arg :status, :verification_status

            @desc "The priority of the contacts to retrieve"
            arg :priority, :contact_priority

            resolve fn
                %{ id: identity }, args, %{ definition: %{ selections: selections } } ->
                    contacts =
                        Enum.reduce(selections, [], fn
                            %Absinthe.Blueprint.Document.Fragment.Inline{ schema_node: %Absinthe.Type.Object{ identifier: object } }, acc when object in [:email_contact, :mobile_contact] -> [object|acc]
                            %Absinthe.Blueprint.Document.Fragment.Inline{ schema_node: %Absinthe.Type.Interface{ identifier: :contact } }, acc -> [:email_contact, :mobile_contact] ++ acc
                            _, acc -> acc
                        end)
                        |> Enum.uniq
                        |> Enum.reduce([], fn
                            :email_contact, acc ->
                                case Sherbet.API.Contact.Email.contacts(identity) do
                                    { :ok, contacts } ->
                                        filter_contacts(contacts, args, acc, fn { status, priority, email } ->
                                            %{ priority: priority, status: status, presentable: email, email: email }
                                        end)
                                    { :error, reason } -> %Donut.GraphQL.Result.Error{ message: reason }
                                end
                            :mobile_contact, acc ->
                                case Sherbet.API.Contact.Mobile.contacts(identity) do
                                    { :ok, contacts } ->
                                        filter_contacts(contacts, args, acc, fn { status, priority, mobile } ->
                                            %{ priority: priority, status: status, presentable: mobile, mobile: mobile }
                                        end)
                                    { :error, reason } -> %Donut.GraphQL.Result.Error{ message: reason }
                                end
                        end)
                        |> Enum.reverse

                    { :ok, contacts }
            end
        end
    end

    defp filter_contacts(contacts, %{ status: status, priority: priority }, acc, get_object) do
        Enum.reduce(contacts, acc, fn contact, acc ->
            case get_object.(contact) do
                object = %{ status: ^status, priority: ^priority } -> [object|acc]
                _ -> acc
            end
        end)
    end
    defp filter_contacts(contacts, %{ priority: priority }, acc, get_object) do
        Enum.reduce(contacts, acc, fn contact, acc ->
            case get_object.(contact) do
                object = %{ priority: ^priority } -> [object|acc]
                _ -> acc
            end
        end)
    end
    defp filter_contacts(contacts, %{ status: status }, acc, get_object) do
        Enum.reduce(contacts, acc, fn contact, acc ->
            case get_object.(contact) do
                object = %{ status: ^status } -> [object|acc]
                _ -> acc
            end
        end)
    end
    defp filter_contacts(contacts, _, acc, get_object) do
        Enum.reduce(contacts, acc, &([get_object.(&1)|&2]))
    end

    result :request_remove_contact, [:string]

    object :contact_mutations do
        @desc "Request a contact be removed from its associated identity"
        field :request_remove_contact, type: result(:request_remove_contact) do
            @desc "The contact to request be removed"
            arg :contact, non_null(:string)

            resolve fn
                %{ contact: contact }, _ ->
                    case Sherbet.API.Contact.Email.request_removal(contact) do
                        :ok -> { :ok, "Sent" }
                        { :error, reason } ->  { :ok, %Donut.GraphQL.Result.Error{ message: reason } }
                    end
            end
        end
    end
end

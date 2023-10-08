class Client < GroupScoped
  include Entity::Queryable

  def method_test
    "#{group_name} for #{name}"
  end

  class Grids
    class IndexGrid

      NAME= :index

      def authorize_request
        true
      end

      def base_query
        query = "SELECT clients.*,
            clients.name as made_up_data,
            groups.name as group_name,
            groups.hierarchy as group_hierarchy
          FROM clients
          INNER JOIN groups ON groups.id = clients.group_id
          WHERE clients.name LIKE :user_name
        "
        binds ={
          user_name: "%#{Client.sanitize_sql_like('')}%"
        }
        Client.sanitize_sql([query, **binds])
      end

      def serialize(query)
        query.as_json(
          {
            methods: :method_test
          }
        )
      end

    end
  end


  TEST_CONSTANTS = 'a'

  # add_grid_query :index, Queries::IndexQuery
  define_all_grid_from Grids

end

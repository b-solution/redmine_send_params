require_dependency 'issue_query'
module  RedmineCommet
  module  Patches
    module IssueQueryPatch
      def self.included(base)
        base.class_eval do
          def non_visible_issue_ids(options={})
            order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

            Issue.
                joins(:status, :project).
                where(statement).
                includes(([:status, :project] + (options[:include] || [])).uniq).
                references(([:status, :project] + (options[:include] || [])).uniq).
                where(options[:conditions]).
                order(order_option).
                joins(joins_for_order_statement(order_option.join(','))).
                limit(options[:limit]).
                offset(options[:offset]).
                pluck(:id)
          rescue ::ActiveRecord::StatementInvalid => e
            raise StatementInvalid.new(e.message)
          end
        end
      end
    end
  end
end
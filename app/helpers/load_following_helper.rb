

module LoadFollowingHelper
  def load_following_to_csv(project, rows)
    encoding = l(:general_csv_encoding)
    columns = [:id, :name, :sold_hours, :estimated_hours]
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
#      csv << columns.collect {|c| Redmine::CodesetUtil.from_utf8(c, encoding) }
      csv << columns
      # csv lines
#      rows.each do |item|
#        csv << columns.collect {|c| Redmine::CodesetUtil.from_utf8(csv_content(c, item), encoding) }
#      end
      export
    end
  end
  def load_following_to_pdf(project, rows)
    ""
  end
end
require 'csv'

def import_from_customer_list_csv(file)
  unfound_tenant_data = []
  failed_save_tenant = []
  CSV.foreach(file, headers: true) do |row|
    resp = { domain: row[6],
             payment: ('annual' if row[13] == '年間'),
             memo: row[19],
             should_notice: row[14] != '×',
             send_invoice: row[15] == '〇',
             usage_start_date: row[9],
             usage_end_date: row[10] }
    if row[13] == '年間'
      pp resp
    end
  end
  { unfound_tenant_data: unfound_tenant_data, failed_save_tenant: failed_save_tenant }
end

def import_from_publish_invoice_csv(file)
  CSV.foreach(file, headers: true) do |row|
    resp = { domain: row[1],
             postal_code: row[3]&.delete('^0-9'),
             addressee: row[2]&.gsub(/[　 ]?(様|御中)$/, ''),
             address: row[4],
             unit_price: row[11]&.delete('^0-9').to_i }
    pp resp
  end
  { unfound_tenant_data: unfound_tenant_data, failed_save_payment: failed_save_payment }
end


# import_from_customer_list_csv('/Users/mercitrau/Downloads/lineworks/customer_list.csv')
import_from_publish_invoice_csv('/Users/mercitrau/Downloads/lineworks/publish_invoice.csv')
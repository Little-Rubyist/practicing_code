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

def import_from_new_customer_list_csv(file)
  CSV.foreach(file, headers: true) do |row|
    resp = { domain_id: row[3],
             domain: row[6],
             payment: row[13],
             memo: row[19],
             send_invoice: row[14],
             should_notice: row[15],
             usage_start_date: row[9],
             usage_end_date: row[10],
             unit_price: row[12],
             payment_type: row[16],
             payjp_id: row[17],
             postal_code: row[20],
             address: row[21],
             company: row[22],
             department: row[23],
             addressee: row[24],
             notification_emails: [row[25], row[26], row[27], row[28], row[29]]}
    pp resp
  end
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
# import_from_publish_invoice_csv('/Users/mercitrau/Downloads/lineworks/publish_invoice.csv')
import_from_new_customer_list_csv('/Users/mercitrau/Downloads/customer_list.csv')

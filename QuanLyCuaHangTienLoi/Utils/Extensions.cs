using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Linq;

namespace QuanLyCuaHangTienLoi.Utils
{
    public static class Extensions
    {
        // Mở rộng cho DataGridView
        public static void ApplyDefaultStyle(this DataGridView dgv)
        {
            dgv.AllowUserToAddRows = false;
            dgv.AllowUserToDeleteRows = false;
            dgv.AllowUserToResizeRows = false;
            dgv.AlternatingRowsDefaultCellStyle.BackColor = Color.AliceBlue;
            dgv.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgv.BackgroundColor = SystemColors.Control;
            dgv.BorderStyle = BorderStyle.Fixed3D;
            dgv.ColumnHeadersDefaultCellStyle.BackColor = Color.SteelBlue;
            dgv.ColumnHeadersDefaultCellStyle.ForeColor = Color.White;
            dgv.ColumnHeadersDefaultCellStyle.Font = new Font(dgv.Font, FontStyle.Bold);
            dgv.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgv.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgv.EnableHeadersVisualStyles = false;
            dgv.GridColor = Color.LightGray;
            dgv.ReadOnly = true;
            dgv.RowHeadersVisible = false;
            dgv.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv.DefaultCellStyle.SelectionBackColor = Color.LightSteelBlue;
            dgv.DefaultCellStyle.SelectionForeColor = Color.Black;
        }

        // Mở rộng cho ComboBox
        public static void LoadItems<T>(this ComboBox comboBox, IEnumerable<T> items,
                                     string displayMember, string valueMember)
        {
            comboBox.DataSource = null;
            comboBox.Items.Clear();

            comboBox.DisplayMember = displayMember;
            comboBox.ValueMember = valueMember;
            comboBox.DataSource = items.ToList();
        }

        // Mở rộng cho DateTimePicker
        public static void SetDateRange(this DateTimePicker dtp,
                                     DateTime? minDate = null, DateTime? maxDate = null)
        {
            if (minDate.HasValue)
            {
                dtp.MinDate = minDate.Value;
            }

            if (maxDate.HasValue)
            {
                dtp.MaxDate = maxDate.Value;
            }
            else
            {
                dtp.MaxDate = DateTime.Today;
            }
        }

        // Mở rộng cho String
        public static bool IsValidEmail(this string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        public static bool IsValidPhoneNumber(this string phoneNumber)
        {
            // Đơn giản hóa kiểm tra số điện thoại Việt Nam
            return System.Text.RegularExpressions.Regex.IsMatch(
                phoneNumber, @"^(0|\+84)(\d{9,10})$");
        }

        // Mở rộng cho DataTable
        public static void ExportToCSV(this DataTable dataTable, string filePath)
        {
            string csv = Helpers.DataTableToCSV(dataTable);
            System.IO.File.WriteAllText(filePath, csv, System.Text.Encoding.UTF8);
        }

        // Mở rộng cho các control
        public static void ClearControls(this Control container)
        {
            foreach (Control ctrl in container.Controls)
            {
                if (ctrl is TextBox)
                {
                    ((TextBox)ctrl).Clear();
                }
                else if (ctrl is ComboBox)
                {
                    ((ComboBox)ctrl).SelectedIndex = -1;
                }
                else if (ctrl is CheckBox)
                {
                    ((CheckBox)ctrl).Checked = false;
                }
                else if (ctrl is RadioButton)
                {
                    ((RadioButton)ctrl).Checked = false;
                }
                else if (ctrl is DateTimePicker)
                {
                    ((DateTimePicker)ctrl).Value = DateTime.Today;
                }
                else if (ctrl is NumericUpDown)
                {
                    ((NumericUpDown)ctrl).Value = 0;
                }
                else if (ctrl.HasChildren)
                {
                    ctrl.ClearControls(); // Đệ quy với container con
                }
            }
        }
    }
}
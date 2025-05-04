using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using QuanLyCuaHangTienLoi.Utils;
using Guna.UI2.WinForms;

namespace QuanLyCuaHangTienLoi.Forms.Auth
{
    public partial class LoginForm : Form
    {
        public LoginForm()
        {
            InitializeComponent();
            // Ghi nhận khởi chạy ứng dụng
            Db.Logger.LogInfo("Ứng dụng đã khởi động - Hiển thị màn hình đăng nhập");
            
            // Thêm thông tin tác giả
            this.Text = "Đăng nhập - Quản lý cửa hàng tiện lợi - steve - vuthuonghai";
        }
        
        private void LoginForm_Load(object sender, EventArgs e)
        {
            // Kiểm tra kết nối cơ sở dữ liệu trước khi hiển thị form đăng nhập
            string errorMessage;
            if (!Utils.DatabaseTester.TestConnection(out errorMessage))
            {
                MessageBox.Show(
                    "Không thể kết nối đến cơ sở dữ liệu!\n\n" + errorMessage + 
                    "\n\nVui lòng kiểm tra chuỗi kết nối trong app.config và đảm bảo SQL Server đang chạy.",
                    "Lỗi kết nối",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            
            // Khởi tạo giao diện đăng nhập với animation
            txtUsername.Focus();
            
            // Load cài đặt "Nhớ mật khẩu" nếu có
            LoadSavedCredentials();
            
            // Thiết lập hiệu ứng hover
            SetupHoverEffects();
            
            // Thiết lập gradient background
            SetupBackgroundGradient();
            
            // Tạo hiệu ứng nhấp nháy nhẹ cho nút đăng nhập
            AnimateLoginButton();
        }
        
        private void btnLogin_Click(object sender, EventArgs e)
        {
            // Xác thực đơn giản cho giai đoạn 1
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;
            
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Vui lòng nhập tên đăng nhập và mật khẩu! 🙏", "Thông báo", 
                                MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            
            try
            {
                // Giai đoạn 1: Chỉ kiểm tra tài khoản mặc định
                if (username == "admin" && password == "Admin@123")
                {
                    // Lưu thông tin đăng nhập nếu người dùng chọn
                    if (chkRememberMe.Checked)
                    {
                        SaveCredentials(username);
                    }
                    
                    Db.Logger.LogInfo($"Đăng nhập thành công: {username}");
                    
                    // Mở form chính (sẽ phát triển ở giai đoạn sau)
                    MessageBox.Show("Đăng nhập thành công! ✨\nMainForm sẽ được phát triển ở giai đoạn sau.", 
                                    "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    
                    // Đóng form đăng nhập
                    this.DialogResult = DialogResult.OK;
                    this.Close();
                }
                else
                {
                    MessageBox.Show("Tên đăng nhập hoặc mật khẩu không đúng! 😢\nTài khoản mặc định: admin/Admin@123", 
                                   "Lỗi đăng nhập", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    Db.Logger.LogWarning($"Đăng nhập thất bại với username: {username}");
                }
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi đăng nhập");
                MessageBox.Show("Đã xảy ra lỗi khi đăng nhập: " + ex.Message, 
                               "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        
        private void LoadSavedCredentials()
        {
            try
            {
                // Đọc username đã lưu (giai đoạn 1 - đơn giản)
                string savedUsername = Properties.Settings.Default.SavedUsername;
                if (!string.IsNullOrEmpty(savedUsername))
                {
                    txtUsername.Text = savedUsername;
                    chkRememberMe.Checked = true;
                    txtPassword.Focus();
                }
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi tải thông tin đăng nhập đã lưu");
            }
        }
        
        private void SaveCredentials(string username)
        {
            try
            {
                // Lưu username (giai đoạn 1 - đơn giản)
                Properties.Settings.Default.SavedUsername = username;
                Properties.Settings.Default.Save();
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi lưu thông tin đăng nhập");
            }
        }
        
        //private void lnkForgotPassword_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        //{
        //    MessageBox.Show("Chức năng quên mật khẩu sẽ được phát triển ở giai đoạn sau. 🔄", 
        //                   "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //}
        private void lnkForgotPassword_LinkClicked(object sender, EventArgs e)
        {
            MessageBox.Show("Chức năng quên mật khẩu sẽ được phát triển ở giai đoạn sau. 🔄",
                           "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        private void btnTestConnection_Click(object sender, EventArgs e)
        {
            Utils.DatabaseTester.ShowConnectionTestForm();
        }
        
        // Thiết lập hiệu ứng hover cho các control
        private void SetupHoverEffects()
        {
            btnLogin.HoverState.FillColor = Color.FromArgb(255, 146, 196);
            btnLogin.HoverState.ForeColor = Color.White;
            txtUsername.HoverState.FillColor = Color.FromArgb(255, 248, 252);
            txtPassword.HoverState.FillColor = Color.FromArgb(255, 248, 252);
        }
        
        // Thiết lập gradient background
        private void SetupBackgroundGradient()
        {
            pnlBackground.FillColor = Color.Transparent;
            pnlBackground.BackColor = Color.Transparent;
        }
        
        // Tạo hiệu ứng nhấp nháy nhẹ cho nút đăng nhập
        private void AnimateLoginButton()
        {
            Timer timer = new Timer();
            timer.Interval = 3000;
            timer.Tick += (sender, e) => {
                btnLogin.FillColor = Color.FromArgb(
                    btnLogin.FillColor.R == 255 ? 250 : 255,
                    btnLogin.FillColor.G,
                    btnLogin.FillColor.B);
            };
            timer.Start();
        }
        
        // Override phương thức OnPaint để vẽ gradient background
        protected override void OnPaint(PaintEventArgs e)
        {
            using (LinearGradientBrush brush = new LinearGradientBrush(
                this.ClientRectangle,
                Color.FromArgb(255, 240, 245), // Hồng nhạt
                Color.FromArgb(230, 230, 250), // Lavender nhạt
                90F))
            {
                e.Graphics.FillRectangle(brush, this.ClientRectangle);
            }
            base.OnPaint(e);
        }
        
        private void InitializeComponent()
        {
            this.pnlBackground = new Guna.UI2.WinForms.Guna2Panel();
            this.pnlLogin = new Guna.UI2.WinForms.Guna2Panel();
            this.btnTestConnection = new Guna.UI2.WinForms.Guna2Button();
            this.lblTitle = new Guna.UI2.WinForms.Guna2HtmlLabel();
            this.txtUsername = new Guna.UI2.WinForms.Guna2TextBox();
            this.txtPassword = new Guna.UI2.WinForms.Guna2TextBox();
            this.btnLogin = new Guna.UI2.WinForms.Guna2Button();
            this.chkRememberMe = new Guna.UI2.WinForms.Guna2CheckBox();
            this.lnkForgotPassword = new Guna.UI2.WinForms.Guna2HtmlLabel();
            this.lblVersion = new Guna.UI2.WinForms.Guna2HtmlLabel();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.pnlBackground.SuspendLayout();
            this.pnlLogin.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // pnlBackground
            // 
            this.pnlBackground.BackColor = System.Drawing.Color.Transparent;
            this.pnlBackground.Controls.Add(this.pnlLogin);
            this.pnlBackground.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlBackground.FillColor = System.Drawing.Color.Transparent;
            this.pnlBackground.Location = new System.Drawing.Point(0, 0);
            this.pnlBackground.Name = "pnlBackground";
            this.pnlBackground.Size = new System.Drawing.Size(800, 500);
            this.pnlBackground.TabIndex = 0;
            // 
            // pnlLogin
            // 
            this.pnlLogin.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.pnlLogin.BackColor = System.Drawing.Color.Transparent;
            this.pnlLogin.BorderRadius = 20;
            this.pnlLogin.Controls.Add(this.btnTestConnection);
            this.pnlLogin.Controls.Add(this.pictureBox1);
            this.pnlLogin.Controls.Add(this.lblTitle);
            this.pnlLogin.Controls.Add(this.txtUsername);
            this.pnlLogin.Controls.Add(this.txtPassword);
            this.pnlLogin.Controls.Add(this.btnLogin);
            this.pnlLogin.Controls.Add(this.chkRememberMe);
            this.pnlLogin.Controls.Add(this.lnkForgotPassword);
            this.pnlLogin.Controls.Add(this.lblVersion);
            this.pnlLogin.FillColor = System.Drawing.Color.White;
            this.pnlLogin.Location = new System.Drawing.Point(230, 70);
            this.pnlLogin.Name = "pnlLogin";
            this.pnlLogin.ShadowDecoration.BorderRadius = 20;
            this.pnlLogin.ShadowDecoration.Color = System.Drawing.Color.FromArgb(((int)(((byte)(236)))), ((int)(((byte)(204)))), ((int)(((byte)(224)))));
            this.pnlLogin.ShadowDecoration.Depth = 12;
            this.pnlLogin.ShadowDecoration.Enabled = true;
            this.pnlLogin.Size = new System.Drawing.Size(340, 360);
            this.pnlLogin.TabIndex = 0;
            // 
            // btnTestConnection
            // 
            this.btnTestConnection.BorderRadius = 8;
            this.btnTestConnection.DisabledState.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTestConnection.DisabledState.CustomBorderColor = System.Drawing.Color.DarkGray;
            this.btnTestConnection.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(169)))), ((int)(((byte)(169)))), ((int)(((byte)(169)))));
            this.btnTestConnection.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(141)))), ((int)(((byte)(141)))), ((int)(((byte)(141)))));
            this.btnTestConnection.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(204)))), ((int)(((byte)(204)))), ((int)(((byte)(255)))));
            this.btnTestConnection.Font = new System.Drawing.Font("Segoe UI", 8F);
            this.btnTestConnection.ForeColor = System.Drawing.Color.White;
            this.btnTestConnection.Location = new System.Drawing.Point(235, 330);
            this.btnTestConnection.Name = "btnTestConnection";
            this.btnTestConnection.Size = new System.Drawing.Size(60, 20);
            this.btnTestConnection.TabIndex = 0;
            this.btnTestConnection.Text = "Kiểm tra DB";
            this.btnTestConnection.Click += new System.EventHandler(this.btnTestConnection_Click);
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.lblTitle.Location = new System.Drawing.Point(45, 110);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(257, 27);
            this.lblTitle.TabIndex = 2;
            this.lblTitle.Text = "✨ Chào mừng bạn trở lại ✨";
            this.lblTitle.TextAlignment = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtUsername
            // 
            this.txtUsername.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(236)))), ((int)(((byte)(204)))), ((int)(((byte)(224)))));
            this.txtUsername.BorderRadius = 10;
            this.txtUsername.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.txtUsername.DefaultText = "";
            this.txtUsername.DisabledState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(208)))), ((int)(((byte)(208)))), ((int)(((byte)(208)))));
            this.txtUsername.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
            this.txtUsername.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(138)))), ((int)(((byte)(138)))), ((int)(((byte)(138)))));
            this.txtUsername.DisabledState.PlaceholderForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(138)))), ((int)(((byte)(138)))), ((int)(((byte)(138)))));
            this.txtUsername.FocusedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.txtUsername.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.txtUsername.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.txtUsername.HoverState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(182)))), ((int)(((byte)(193)))));
            this.txtUsername.IconLeftOffset = new System.Drawing.Point(5, 0);
            this.txtUsername.Location = new System.Drawing.Point(45, 150);
            this.txtUsername.Name = "txtUsername";
            this.txtUsername.PlaceholderForeColor = System.Drawing.Color.Silver;
            this.txtUsername.PlaceholderText = "Tên đăng nhập";
            this.txtUsername.SelectedText = "";
            this.txtUsername.Size = new System.Drawing.Size(250, 40);
            this.txtUsername.TabIndex = 3;
            // 
            // txtPassword
            // 
            this.txtPassword.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(236)))), ((int)(((byte)(204)))), ((int)(((byte)(224)))));
            this.txtPassword.BorderRadius = 10;
            this.txtPassword.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.txtPassword.DefaultText = "";
            this.txtPassword.DisabledState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(208)))), ((int)(((byte)(208)))), ((int)(((byte)(208)))));
            this.txtPassword.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
            this.txtPassword.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(138)))), ((int)(((byte)(138)))), ((int)(((byte)(138)))));
            this.txtPassword.DisabledState.PlaceholderForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(138)))), ((int)(((byte)(138)))), ((int)(((byte)(138)))));
            this.txtPassword.FocusedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.txtPassword.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.txtPassword.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.txtPassword.HoverState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(182)))), ((int)(((byte)(193)))));
            this.txtPassword.IconLeftOffset = new System.Drawing.Point(5, 0);
            this.txtPassword.Location = new System.Drawing.Point(45, 200);
            this.txtPassword.Name = "txtPassword";
            this.txtPassword.PasswordChar = '●';
            this.txtPassword.PlaceholderForeColor = System.Drawing.Color.Silver;
            this.txtPassword.PlaceholderText = "Mật khẩu";
            this.txtPassword.SelectedText = "";
            this.txtPassword.Size = new System.Drawing.Size(250, 40);
            this.txtPassword.TabIndex = 4;
            // 
            // btnLogin
            // 
            this.btnLogin.BorderRadius = 12;
            this.btnLogin.DisabledState.BorderColor = System.Drawing.Color.DarkGray;
            this.btnLogin.DisabledState.CustomBorderColor = System.Drawing.Color.DarkGray;
            this.btnLogin.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(169)))), ((int)(((byte)(169)))), ((int)(((byte)(169)))));
            this.btnLogin.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(141)))), ((int)(((byte)(141)))), ((int)(((byte)(141)))));
            this.btnLogin.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.btnLogin.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Bold);
            this.btnLogin.ForeColor = System.Drawing.Color.White;
            this.btnLogin.Location = new System.Drawing.Point(45, 285);
            this.btnLogin.Name = "btnLogin";
            this.btnLogin.Size = new System.Drawing.Size(250, 40);
            this.btnLogin.TabIndex = 5;
            this.btnLogin.Text = "✨ ĐĂNG NHẬP ✨";
            this.btnLogin.Click += new System.EventHandler(this.btnLogin_Click);
            // 
            // chkRememberMe
            // 
            this.chkRememberMe.AutoSize = true;
            this.chkRememberMe.CheckedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.chkRememberMe.CheckedState.BorderRadius = 3;
            this.chkRememberMe.CheckedState.BorderThickness = 0;
            this.chkRememberMe.CheckedState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.chkRememberMe.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.chkRememberMe.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.chkRememberMe.Location = new System.Drawing.Point(45, 250);
            this.chkRememberMe.Name = "chkRememberMe";
            this.chkRememberMe.Size = new System.Drawing.Size(117, 19);
            this.chkRememberMe.TabIndex = 6;
            this.chkRememberMe.Text = "🍓 Nhớ mật khẩu";
            this.chkRememberMe.UncheckedState.BorderRadius = 0;
            this.chkRememberMe.UncheckedState.BorderThickness = 0;
            // 
            // lnkForgotPassword
            // 
            this.lnkForgotPassword.BackColor = System.Drawing.Color.Transparent;
            this.lnkForgotPassword.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.lnkForgotPassword.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(105)))), ((int)(((byte)(180)))));
            this.lnkForgotPassword.Location = new System.Drawing.Point(170, 250);
            this.lnkForgotPassword.Name = "lnkForgotPassword";
            this.lnkForgotPassword.Size = new System.Drawing.Size(105, 17);
            this.lnkForgotPassword.TabIndex = 7;
            this.lnkForgotPassword.Text = "Quên mật khẩu? ✨";
            this.lnkForgotPassword.Click += new System.EventHandler(this.lnkForgotPassword_LinkClicked);
            // 
            // lblVersion
            // 
            this.lblVersion.BackColor = System.Drawing.Color.Transparent;
            this.lblVersion.Font = new System.Drawing.Font("Segoe UI", 8F);
            this.lblVersion.ForeColor = System.Drawing.Color.Gray;
            this.lblVersion.Location = new System.Drawing.Point(45, 330);
            this.lblVersion.Name = "lblVersion";
            this.lblVersion.Size = new System.Drawing.Size(176, 15);
            this.lblVersion.TabIndex = 8;
            this.lblVersion.Text = "✨ Phiên bản 1.0.0 - made with ✨";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::QuanLyCuaHangTienLoi.Properties.Resources.runout_logo2;
            this.pictureBox1.Location = new System.Drawing.Point(130, 20);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(80, 80);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox1.TabIndex = 1;
            this.pictureBox1.TabStop = false;
            // 
            // LoginForm
            // 
            this.AcceptButton = this.btnLogin;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 500);
            this.Controls.Add(this.pnlBackground);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.Name = "LoginForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Đăng nhập - Quản lý cửa hàng tiện lợi - steve - vuthuonghai";
            this.Load += new System.EventHandler(this.LoginForm_Load);
            this.pnlBackground.ResumeLayout(false);
            this.pnlLogin.ResumeLayout(false);
            this.pnlLogin.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);

        }
        
        private Guna.UI2.WinForms.Guna2Panel pnlBackground;
        private Guna.UI2.WinForms.Guna2Panel pnlLogin;
        private System.Windows.Forms.PictureBox pictureBox1;
        private Guna.UI2.WinForms.Guna2HtmlLabel lblTitle;
        private Guna.UI2.WinForms.Guna2TextBox txtUsername;
        private Guna.UI2.WinForms.Guna2TextBox txtPassword;
        private Guna.UI2.WinForms.Guna2Button btnLogin;
        private Guna.UI2.WinForms.Guna2CheckBox chkRememberMe;
        private Guna.UI2.WinForms.Guna2HtmlLabel lnkForgotPassword;
        private Guna.UI2.WinForms.Guna2HtmlLabel lblVersion;
        private Guna.UI2.WinForms.Guna2Button btnTestConnection;
    }
}
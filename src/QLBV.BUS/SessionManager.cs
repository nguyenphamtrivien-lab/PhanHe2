using QLBV.DTO;

namespace QLBV.BUS
{
    public static class SessionManager
    {
        public static UserSessionDTO CurrentUser { get; private set; }
        public static bool IsLoggedIn => CurrentUser != null;
        public static void SetSession(UserSessionDTO session) { CurrentUser = session; }
        public static void ClearSession() { CurrentUser = null; }
        public static bool IsRole(string vaiTro) { return CurrentUser?.VaiTro == vaiTro; }

        public const string ROLE_DPV = "Dieu phoi vien";
        public const string ROLE_BS = "Bac si/Y si";
        public const string ROLE_KTV = "Ky thuat vien";
        public const string ROLE_BN = "Benh nhan";
    }
}

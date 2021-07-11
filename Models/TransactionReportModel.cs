namespace AKStore.Models
{
    public class TransactionReportModel
    {
        public int Id { get; set; }
        public string StoreName { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int SerialNo { get; set; }
        public int CustomerId { get; set; }
        public decimal OpenningBalance { get; set; }
        public decimal PurchasedAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal OutStanding { get; set; }

    }
}
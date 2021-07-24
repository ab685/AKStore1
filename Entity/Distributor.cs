using System;

namespace AKStore.Entity
{
    public class Distributor: UsersBacicFields
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int UserId { get; set; }
        public int AdminId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public int? UpdatedByUserId { get; set; }
    } }
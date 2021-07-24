using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using PagedList;
using System;
using System.Collections.Generic;
using System.Web;

namespace AKStore.Services
{
    public class CustomerService : BaseService, ICustomerService
    {

        private readonly ICustomerRepository _customerRepository;
        private readonly IUserRepository _userRepository;
        public Mapper.MapperConfig mapper;
        public CustomerService()
        {

            _customerRepository = new CustomerRepository();
            _userRepository = new UserRepository();
            mapper = new Mapper.MapperConfig();
        }

        public IEnumerable<CustomerModel> GetCustomerData(int distributorId)
        {
            var customers = _customerRepository.GetCustomers(distributorId);
            return AutoMapper.Mapper.Map<IEnumerable<CustomerModel>>(customers);
        }
        public CustomerModel GetCustomerDataById(int id)
        {
            var customer = _customerRepository.GetCustomerById(id);
            return AutoMapper.Mapper.Map<CustomerModel>(customer);
        }

        public Tuple<bool, string> UpsertCustomer(CustomerModel customerModel)
        {
            var data = new Tuple<bool, string>(false, "");
            if (customerModel.Id == 0)
            {

                Users user = new Users()
                {
                    FirstName = customerModel.FirstName,
                    LastName = customerModel.LastName,
                    UserName = customerModel.UserName,
                    Password = customerModel.Password,
                    RoleId = 6,
                    IsActive = true,
                    InsertedDate = DateTime.Now,
                    LoggedInCount = 0,
                    PhNo1 = customerModel.PhNo1,
                    PhNo2 = customerModel.PhNo2,
                    Address = customerModel.Address,
                    PostalCode = customerModel.PostalCode
                };
                var userId = _userRepository.UpsertUser(user);
                if (userId > 0)
                {
                    Customer customer = new Customer()
                    {

                        StoreName = customerModel.StoreName,
                        InsertedDate = DateTime.Now,
                        InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]),
                        UserId = userId
                    };
                    data = _customerRepository.UpsertCustomer(customer);

                }

            }
            else
            {
                var customer = _customerRepository.GetById(customerModel.Id);
                if (customer != null)
                {
                    var user = _userRepository.GetById(customer.UserId);
                    if (user != null)
                    {
                        user.FirstName = customerModel.FirstName;
                        user.LastName = customerModel.LastName;
                        user.IsActive = true;
                        user.UpdatedDate = DateTime.Now;
                        user.Address = customerModel.Address;
                        user.PostalCode = customerModel.PostalCode;
                        user.PhNo1 = customerModel.PhNo1;
                        user.PhNo2 = customerModel.PhNo2;
                        _userRepository.UpsertUser(user);
                    }


                    customer.StoreName = customerModel.StoreName;
                    customer.UpdatedDate = DateTime.Now;
                    customer.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    data = _customerRepository.UpsertCustomer(customer);
                }

            }
            return data;

            //var customer = AutoMapper.Mapper.Map<Customer>(customerModel);
            //return _customerRepository.UpsertCustomer(customer);

        }

        public Tuple<bool, string> DeleteCustomer(int customerId)
        {
            return _customerRepository.DeleteCustomer(customerId);
        }

        public IPagedList<ProductModel> GetProductDataByCustomerId(int customerId, string search, int? page)
        {
            return _customerRepository.GetProductDataByCustomerId(customerId, search).ToPagedList(page ?? 1, 200);
        }
        public List<OrderModels> GetOrdersByCustomerId(int customerId)
        {
            return _customerRepository.GetOrdersByCustomerId(customerId);
        }
    }
}

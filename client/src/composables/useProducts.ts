import { ref, Ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useProductStore } from '@/store/useProductStore'
import { ProductType, CreateProductVariablesType, UpdateProductVariablesType, ProductTypeType, ProductStatusType } from '@/_types/types'
import mockProducts from '@/mock_data/products.json'

interface UseProducts {
  formData: Ref<CreateProductVariablesType>
  products: Ref<ProductType[]>
  product: Ref<ProductType>
  handleFetchProducts: () => Promise<boolean>
  createProduct: (variables: CreateProductVariablesType) => Promise<boolean>
  updateProduct: (variables: UpdateProductVariablesType) => Promise<boolean>
}

const useProducts = (): UseProducts => {
  const route = useRoute()

  const productStore = useProductStore()
  const { fetchProducts, createProduct, updateProduct } = productStore
  const { products } = storeToRefs(productStore)

  const page = 1
  const perPage = 10

  const handleFetchProducts = (): Promise<boolean> => fetchProducts({ page, perPage })

  const id = route.params.id as string
  const idx = Number(id) - 1
  const product = ref<ProductType>({
    ...mockProducts[idx],
    status: mockProducts[idx].status as ProductStatusType
  } as ProductType)

  const getForm = (): CreateProductVariablesType => ({
    name: id ? product.value.id : '',
    slug: id ? product.value.slug : '',
    status: id ? product.value.status as ProductStatusType || 'unknown' : 'unknown',
    price: id ? product.value.price : { amount: '', currency: 'USD' },
    productType: id ? product.value.productType as ProductTypeType : '',
    categories: id ? product.value.categories : [],
    description: id ? product.value.description : ''
  })

  const formData = ref<CreateProductVariablesType>(getForm())

  watch(
    product,
    () => formData.value = { ...getForm() },
    { deep: true }
  )

  return {
    products,
    product,
    formData,
    handleFetchProducts,
    createProduct,
    updateProduct
  }
}

export default useProducts

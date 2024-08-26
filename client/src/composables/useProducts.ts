import { ref, Ref } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useProductStore } from '@/store/useProductStore'
import { ProductType, CreateProductVariablesType, UpdateProductVariablesType, ProductTypeType, ProductStatusType } from '@/_types/types'

interface UseProducts {
  formData: Ref<CreateProductVariablesType>
  products: Ref<ProductType[]>
  product: Ref<ProductType>
  handleFetchProducts: () => Promise<boolean>
  handleFetchProduct: () => Promise<boolean>
  createProduct: (variables: CreateProductVariablesType) => Promise<boolean>
  updateProduct: (variables: UpdateProductVariablesType) => Promise<boolean>
}

const useProducts = (): UseProducts => {
  const route = useRoute()

  const productStore = useProductStore()
  const { fetchProducts, fetchProduct, createProduct, updateProduct } = productStore
  const { products, product } = storeToRefs(productStore)

  const page = 1
  const perPage = 10

  const handleFetchProducts = (): Promise<boolean> => fetchProducts({ page, perPage })

  const id = route.params.id as string

  const handleFetchProduct = async (): Promise<boolean> => {
    const success = await fetchProduct(route.params.id as string)
    if (success && product.value) {
      formData.value = {
        name: product.value.name,
        slug: product.value.slug,
        status: product.value.status as ProductStatusType,
        price: {
          amount: product.value.price?.amount || '',
          currency: product.value.price?.currency || 'USD'
        },
        productType: product.value.productType as ProductTypeType,
        categories: product.value.categories,
        description: product.value.description
      }
    }

    return success
  }

  const getForm = (): CreateProductVariablesType => ({
    name: id ? product.value?.id : '',
    slug: id ? product.value?.slug : '',
    status: id ? product.value?.status as ProductStatusType || 'unknown' : 'unknown',
    price:  {
      amount: id ? product.value?.price?.amount : '',
      currency: id ? product.value?.price?.currency : 'USD'
    },
    productType: id ? product.value?.productType as ProductTypeType || 'unknown' : '',
    categories: id ? product.value?.categories : [],
    description: id ? product.value?.description : ''
  })

  const formData = ref<CreateProductVariablesType>(getForm())

  return {
    products,
    product,
    formData,
    handleFetchProducts,
    handleFetchProduct,
    createProduct,
    updateProduct
  }
}

export default useProducts

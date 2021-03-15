package es.codeurjc.mca.practica_1_cloud_ordinaria_2021.image;

import java.io.File;
import java.util.UUID;

import javax.annotation.PostConstruct;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.PutObjectRequest;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@Service("storageService")
@Profile("production")
public class S3ImageService implements ImageService {

    @Value("${amazon.s3.bucket-name}")
    private String bucketName;

    @Value("${amazon.s3.region}")
    private String region;

    private AmazonS3 s3;

    @PostConstruct
    public void initS3Client() {
        this.s3 = AmazonS3ClientBuilder.standard()
                    .withRegion(Regions.fromName(region))
                    .build();
        createBucketIfNotExist();
    }

    private void createBucketIfNotExist() {
        if (!s3.doesBucketExistV2(bucketName)) {
            s3.createBucket(bucketName);
        }
    }

    @Override
    public String createImage(MultipartFile multiPartFile) {
        String fileName = "image_" + UUID.randomUUID() + "_" +multiPartFile.getOriginalFilename();
        File file = new File(System.getProperty("java.io.tmpdir") + "/" + fileName);
        try {
            multiPartFile.transferTo(file);
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Can't save image on S3", ex);
        }
        PutObjectRequest por = new PutObjectRequest(bucketName, fileName, file);
        por.setCannedAcl(CannedAccessControlList.PublicRead);
        s3.putObject(por);
        file.delete();
        return s3.getUrl(bucketName, fileName).toString();
    }

    @Override
    public void deleteImage(String image) {
        String[] tokens = image.split("/");
        String fileName = tokens[tokens.length - 1];
        s3.deleteObject(bucketName, fileName);
    }

}
